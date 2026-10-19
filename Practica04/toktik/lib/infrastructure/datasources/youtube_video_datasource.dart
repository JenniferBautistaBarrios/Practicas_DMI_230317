import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/datasources/video_posts_datasource.dart';
import '../../domain/entities/video_post.dart';
import '../models/comment_model.dart';
import '../models/video_model.dart';

/// Read-only access to YouTube Data API v3.
///
/// Supply the key with --dart-define=YOUTUBE_API_KEY=... or inject [apiKey].
/// Restrict the key to YouTube Data API v3 and the intended application.
class YouTubeVideoDatasource implements VideoPostDatasource {
  static const _baseUrl = 'www.googleapis.com';
  static const _apiKeyFromBuild = String.fromEnvironment('YOUTUBE_API_KEY');

  final http.Client _client;
  final bool _ownsClient;
  final String apiKey;

  YouTubeVideoDatasource({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      apiKey = (apiKey ?? _apiKeyFromBuild).trim();

  /// Returns the most popular videos for a region, optionally in a category.
  Future<List<VideoModel>> getTrendingVideos({
    String regionCode = 'MX',
    String? categoryId,
    int maxResults = 20,
  }) async {
    final query = <String, String>{
      'part': 'snippet,statistics,status',
      'chart': 'mostPopular',
      'regionCode': regionCode,
      'maxResults': '${_limit(maxResults)}',
    };
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      query['videoCategoryId'] = categoryId.trim();
    }

    final json = await _get('/youtube/v3/videos', query);
    return _videoItems(json);
  }

  /// Retrieves current metadata for a fixed set of IDs for the embedded feed.
  Future<List<VideoModel>> getVideosByIds(Iterable<String> videoIds) async {
    final ids = videoIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (ids.isEmpty) return [];

    final json = await _get('/youtube/v3/videos', {
      'part': 'snippet,statistics,status',
      'id': ids.join(','),
      'hl': 'es',
    });
    return (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VideoModel.fromJson)
        .where((video) => video.id.isNotEmpty)
        .toList();
  }

  /// Gets public top-level comments for a video. Comments disabled by the
  /// owner are reported by YouTube as a normal API error.
  Future<List<CommentModel>> getCommentsByVideoId(
    String videoId, {
    int maxResults = 10,
  }) async {
    final id = videoId.trim();
    if (id.isEmpty) return [];

    final json = await _get('/youtube/v3/commentThreads', {
      'part': 'snippet',
      'videoId': id,
      'order': 'relevance',
      'maxResults': '${_limit(maxResults)}',
      'textFormat': 'plainText',
    });

    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromThreadJson)
        .where((comment) => comment.text.trim().isNotEmpty)
        .toList();
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (page != 1) return [];
    return (await getTrendingVideos()).map(_asVideoPost).toList();
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async => [];

  /// Searches videos by [term], [categoryId], or both.
  ///
  /// Search results do not include view counts, so this makes a second
  /// videos.list request to map complete VideoModel records.
  Future<List<VideoModel>> searchVideos({
    String? term,
    String? categoryId,
    String regionCode = 'MX',
    int maxResults = 20,
  }) async => (await searchVideosPage(
    term: term,
    categoryId: categoryId,
    regionCode: regionCode,
    maxResults: maxResults,
  )).videos;

  Future<VideoModelPage> searchVideosPage({
    String? term,
    String? categoryId,
    String regionCode = 'MX',
    int maxResults = 20,
    String? pageToken,
  }) async {
    final normalizedTerm = term?.trim();
    final normalizedCategory = categoryId?.trim();
    if ((normalizedTerm == null || normalizedTerm.isEmpty) &&
        (normalizedCategory == null || normalizedCategory.isEmpty)) {
      throw ArgumentError('Indica un término de búsqueda o un categoryId.');
    }

    final query = <String, String>{
      'part': 'snippet',
      'type': 'video',
      'videoEmbeddable': 'true',
      'regionCode': regionCode,
      'maxResults': '${_limit(maxResults)}',
      if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
    };
    if (normalizedTerm != null && normalizedTerm.isNotEmpty) {
      query['q'] = normalizedTerm;
    }
    if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
      query['videoCategoryId'] = normalizedCategory;
    }

    final searchJson = await _get('/youtube/v3/search', query);
    final searchItems = searchJson['items'] as List<dynamic>? ?? [];
    final ids = searchItems
        .whereType<Map<String, dynamic>>()
        .map((item) => item['id'] as Map<String, dynamic>? ?? {})
        .map((id) => id['videoId'] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    final nextPageToken = searchJson['nextPageToken'] as String?;
    if (ids.isEmpty) {
      return VideoModelPage(videos: const [], nextPageToken: nextPageToken);
    }

    final detailsJson = await _get('/youtube/v3/videos', {
      'part': 'snippet,statistics,status',
      'id': ids.join(','),
    });
    final models = _videoItems(detailsJson);

    // videos.list may return items in a different order; keep search ranking.
    final byId = {for (final video in models) video.id: video};
    return VideoModelPage(
      videos: [for (final id in ids) if (byId.containsKey(id)) byId[id]!],
      nextPageToken: nextPageToken,
    );
  }

  List<VideoPost> toVideoPosts(List<VideoModel> videos) =>
      videos.map(_asVideoPost).toList();

  VideoPost _asVideoPost(VideoModel video) => VideoPost(
    caption: video.title,
    description: video.channelTitle,
    videoUrl: 'https://www.youtube.com/watch?v=${video.id}',
    views: video.viewCount,
    source: VideoSource.youtube,
    externalId: video.id,
    thumbnailUrl: video.thumbnailUrl,
    attributionUrl: 'https://www.youtube.com/watch?v=${video.id}',
  );

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.https(_baseUrl, path, query);
    final response = await _client
        .get(uri, headers: {'x-goog-api-key': _requiredApiKey()})
        .timeout(const Duration(seconds: 20));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respuesta JSON inesperada de YouTube.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ??
          'YouTube Data API respondió HTTP ${response.statusCode}.';
      final details = error?['errors'] as List<dynamic>? ?? [];
      final firstDetail = details.isNotEmpty && details.first is Map
          ? Map<String, dynamic>.from(details.first as Map)
          : <String, dynamic>{};
      throw YouTubeApiException(
        response.statusCode,
        message,
        reason: firstDetail['reason'] as String?,
      );
    }
    return decoded;
  }

  List<VideoModel> _videoItems(Map<String, dynamic> json) =>
      (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .where((item) {
            final status = item['status'] as Map<String, dynamic>?;
            return status?['embeddable'] != false;
          })
          .map(VideoModel.fromJson)
          .where((video) => video.id.isNotEmpty)
          .toList();

  String _requiredApiKey() {
    if (apiKey.isEmpty) {
      throw StateError(
        'La clave de YouTube no se incluyó al compilar la app. Detén la app y '
        'vuelve a iniciarla con '
        '--dart-define-from-file=api_credentials.json.',
      );
    }
    return apiKey;
  }

  int _limit(int maxResults) => maxResults.clamp(1, 50).toInt();

  void close() {
    if (_ownsClient) _client.close();
  }
}

class YouTubeApiException implements Exception {
  final int statusCode;
  final String message;
  final String? reason;

  const YouTubeApiException(this.statusCode, this.message, {this.reason});

  @override
  String toString() => 'YouTubeApiException($statusCode, $reason): $message';
}
