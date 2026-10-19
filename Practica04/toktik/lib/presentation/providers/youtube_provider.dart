import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/youtube_comment.dart';
import '../../domain/entities/youtube_video.dart';
import '../../domain/repositories/youtube_repository.dart';
import '../../infrastructure/datasources/youtube_video_datasource.dart';

class YouTubeProvider extends ChangeNotifier {
  static const _excludedKey = 'youtube.unavailable_video_ids.v1';
  final YouTubeRepository repository;
  final SharedPreferences storage;
  final Set<String> _excludedVideoIds;
  final Map<String, List<YouTubeComment>> _commentsCache = {};

  YouTubeProvider(this.repository, {required this.storage})
    : _excludedVideoIds = storage.getStringList(_excludedKey)?.toSet() ?? {};

  List<YouTubeVideo> videos = const [];
  List<YouTubeVideo> trendingVideos = const [];
  List<YouTubeComment> comments = const [];
  bool loadingVideos = false;
  bool loadingTrendingVideos = false;
  bool loadingMoreVideos = false;
  bool hasMoreVideos = false;
  bool loadingComments = false;
  String? error;
  String? trendingError;
  String? commentsError;
  String? commentsReason;
  String? commentsApiMessage;
  String? selectedVideoId;
  int _request = 0;
  String _query = '';
  String? _nextPageToken;
  bool _trendingRequested = false;

  Future<void> _excludeVideo(String videoId) async {
    _excludedVideoIds.add(videoId);
    videos = videos.where((video) => video.id != videoId).toList();
    notifyListeners();
    await _persistExcludedVideoIds();
  }

  Future<void> _persistExcludedVideoIds() async {
    try {
      await storage.setStringList(_excludedKey, _excludedVideoIds.toList());
    } catch (_) {
      // A storage failure must not keep an unavailable video in the feed or
      // turn a comments error into an app crash.
    }
  }

  Future<void> skipUnavailableVideo(String videoId) => _excludeVideo(videoId);

  Future<void> loadTrendingMusic({bool force = false}) async {
    if (loadingTrendingVideos || (_trendingRequested && !force)) return;
    if (repository is! TrendingYouTubeRepository) return;
    _trendingRequested = true;
    loadingTrendingVideos = true;
    trendingError = null;
    notifyListeners();
    try {
      trendingVideos = await (repository as TrendingYouTubeRepository)
          .getTrendingMusicVideos();
    } catch (exception) {
      trendingError = exception.toString();
    } finally {
      loadingTrendingVideos = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final request = ++_request;
    _query = query;
    _nextPageToken = null;
    hasMoreVideos = false;
    loadingMoreVideos = false;
    loadingVideos = true;
    error = null;
    videos = const [];
    notifyListeners();
    try {
      if (repository is PagedYouTubeRepository) {
        final page = await (repository as PagedYouTubeRepository)
            .searchVideosPage(query);
        if (request != _request) return;
        videos = page.videos;
        _nextPageToken = page.nextPageToken;
        hasMoreVideos = _nextPageToken != null;
      } else {
        videos = await repository.searchVideos(query);
      }
      if (request != _request) return;
    } catch (exception) {
      if (request != _request) return;
      error = exception.toString();
    } finally {
      if (request == _request) {
        loadingVideos = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadVideosByIds(Iterable<String> videoIds) async {
    final ids = videoIds.toList();
    final request = ++_request;
    _nextPageToken = null;
    hasMoreVideos = false;
    loadingMoreVideos = false;
    loadingVideos = true;
    error = null;
    videos = const [];
    notifyListeners();
    try {
      final source = repository;
      if (source is! YouTubeVideosByIdsRepository) {
        throw StateError('El repositorio de YouTube no permite cargar estos videos.');
      }
      final videosRepository = source as YouTubeVideosByIdsRepository;
      final result = await videosRepository.getVideosByIds(ids);
      if (request != _request) return;
      final byId = {for (final video in result) video.id: video};
      videos = [
        for (final id in ids)
          byId[id] ??
              YouTubeVideo(
                id: id,
                title: 'Video de YouTube',
                channel: 'YouTube',
                thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
                views: 0,
                likes: null,
              ),
      ];
    } catch (exception) {
      if (request != _request) return;
      // Keep the user's four requested videos available even if the metadata
      // API is unavailable; iframe playback itself does not need the API key.
      videos = [
        for (final id in ids)
          YouTubeVideo(
            id: id,
            title: 'Video de YouTube',
            channel: 'YouTube',
            thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
            views: 0,
            likes: null,
          ),
      ];
    } finally {
      if (request == _request) {
        loadingVideos = false;
        notifyListeners();
      }
    }
  }

  /// Searches only for YouTube videos that the API marks as embeddable.
  /// Keep the page token so Discovery can request more Shorts as needed.
  Future<void> loadEmbeddableVideos({int limit = 20}) async {
    final request = ++_request;
    loadingVideos = true;
    loadingMoreVideos = false;
    hasMoreVideos = false;
    error = null;
    videos = const [];
    notifyListeners();
    try {
      final source = repository;
      if (source is! PagedYouTubeRepository) {
        throw StateError('El repositorio no permite buscar videos insertables.');
      }
      final pagedSource = source as PagedYouTubeRepository;
      _query = '#shorts musica en español';
      _nextPageToken = null;
      final page = await pagedSource
          .searchVideosPage(_query, limit: 50)
          .timeout(const Duration(seconds: 25));
      if (request != _request) return;
      _nextPageToken = page.nextPageToken;
      hasMoreVideos = _nextPageToken != null;
      final available = <YouTubeVideo>[];
      for (final video in page.videos) {
        if (_excludedVideoIds.contains(video.id)) continue;
        available.add(video);
        if (available.length >= limit) break;
      }
      if (_excludedVideoIds.isNotEmpty) await _persistExcludedVideoIds();
      videos = available;
      if (videos.isEmpty) {
        error = 'No hay videos disponibles que permitan reproducción integrada.';
      }
    } catch (exception) {
      if (request != _request) return;
      error = _videoSearchError(exception);
    } finally {
      if (request == _request) {
        loadingVideos = false;
        notifyListeners();
      }
    }
  }

  String _videoSearchError(Object exception) {
    if (exception is YouTubeApiException &&
        (exception.reason == 'quotaExceeded' ||
            exception.reason == 'rateLimitExceeded')) {
      return 'Se agotó la cuota diaria de búsqueda de YouTube. Cambia o amplía la cuota de la API key del backend y vuelve a intentarlo.';
    }
    return 'No se pudieron buscar videos permitidos. $exception';
  }

  Future<void> loadMoreVideos() async {
    final token = _nextPageToken;
    if (loadingVideos || loadingMoreVideos || !hasMoreVideos || token == null) {
      return;
    }
    final request = _request;
    loadingMoreVideos = true;
    error = null;
    notifyListeners();
    try {
      final page = await (repository as PagedYouTubeRepository)
          .searchVideosPage(_query, pageToken: token);
      if (request != _request) return;
      final ids = videos.map((video) => video.id).toSet();
      videos = [
        ...videos,
        ...page.videos.where(
          (video) =>
              !_excludedVideoIds.contains(video.id) && ids.add(video.id),
        ),
      ];
      _nextPageToken = page.nextPageToken;
      hasMoreVideos = _nextPageToken != null;
    } catch (exception) {
      if (request == _request) error = _videoSearchError(exception);
    } finally {
      if (request == _request) {
        loadingMoreVideos = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadComments(String videoId) async {
    selectedVideoId = videoId;
    loadingComments = true;
    commentsError = null;
    commentsReason = null;
    commentsApiMessage = null;
    comments = const [];
    notifyListeners();
    try {
      final cachedComments = _commentsCache[videoId];
      comments = cachedComments ?? await repository.getComments(videoId);
      _commentsCache[videoId] = comments;
    } catch (exception) {
      commentsError = exception.toString();
      if (exception is YouTubeApiException) {
        commentsReason = exception.reason;
        commentsApiMessage = exception.message;
      }
    } finally {
      loadingComments = false;
      notifyListeners();
    }
  }
}
