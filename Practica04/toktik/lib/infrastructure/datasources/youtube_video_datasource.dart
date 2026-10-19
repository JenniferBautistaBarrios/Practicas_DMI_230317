import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/datasources/video_posts_datasource.dart';
import '../../domain/entities/video_post.dart';
import '../models/comment_model.dart';
import '../models/video_model.dart';

/// Read-only access to the app's backend proxy for YouTube Data API v3.
class YouTubeVideoDatasource implements VideoPostDatasource {
  static const _configuredBackend = String.fromEnvironment(
    'YOUTUBE_API_BASE_URL',
  );

  final http.Client _client;
  final bool _ownsClient;
  final Uri _backend;

  YouTubeVideoDatasource({http.Client? client, String? backendUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      _backend = Uri.parse(
        (backendUrl ?? _defaultBackend).replaceFirst(RegExp(r'/$'), ''),
      );

  static String get _defaultBackend => _configuredBackend.isNotEmpty
      ? _configuredBackend
      : kIsWeb
      ? 'http://127.0.0.1:3000'
      : defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:3000'
      : 'http://127.0.0.1:3000';

  /// Returns the most popular videos for a region, optionally in a category.
  Future<List<VideoModel>> getTrendingVideos({
    String regionCode = 'MX',
    String? categoryId,
    int maxResults = 20,
  }) async {
    final query = <String, String>{
      'part': 'snippet,statistics,status,contentDetails',
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
      'part': 'snippet,statistics,status,contentDetails',
      'id': ids.join(','),
      'hl': 'es',
    });
    return _videoItems(json);
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
      // Discovery uses an in-app iframe, so require both YouTube's explicit
      // embeddable flag and syndication outside youtube.com.
      'videoEmbeddable': 'true',
      'videoSyndicated': 'true',
      'videoDuration': 'short',
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
      'part': 'snippet,statistics,status,contentDetails',
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
    final uri = _backend.replace(
      path: '/api${path}',
      queryParameters: query,
    );
    final response = await _client
        .get(uri)
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
        errors: details
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    }
    return decoded;
  }

  List<VideoModel> _videoItems(Map<String, dynamic> json) =>
      (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .where((item) {
            final status = item['status'] as Map<String, dynamic>?;
            final details = item['contentDetails'] as Map<String, dynamic>?;
            final rating = details?['contentRating'] as Map<String, dynamic>?;
            final region = details?['regionRestriction'] as Map<String, dynamic>?;
            final allowed = region?['allowed'] as List<dynamic>?;
            final blocked = region?['blocked'] as List<dynamic>? ?? const [];
            final availableInMexico = allowed == null || allowed.contains('MX');
            return status?['embeddable'] == true &&
                rating?['ytRating'] != 'ytAgeRestricted' &&
                availableInMexico &&
                !blocked.contains('MX');
          })
          .map(VideoModel.fromJson)
          .where((video) => video.id.isNotEmpty)
          .toList();

  int _limit(int maxResults) => maxResults.clamp(1, 50).toInt();

  void close() {
    if (_ownsClient) _client.close();
  }
}

class YouTubeApiException implements Exception {
  final int statusCode;
  final String message;
  final String? reason;
  final List<Map<String, dynamic>> errors;

  const YouTubeApiException(
    this.statusCode,
    this.message, {
    this.reason,
    this.errors = const [],
  });

  bool get commentsDisabled => reason == 'commentsDisabled';

  @override
  String toString() => 'YouTubeApiException($statusCode, $reason): $message';
}
