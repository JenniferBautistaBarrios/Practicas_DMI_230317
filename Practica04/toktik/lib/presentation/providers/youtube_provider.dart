import 'package:flutter/foundation.dart';

import '../../domain/entities/youtube_comment.dart';
import '../../domain/entities/youtube_video.dart';
import '../../domain/repositories/youtube_repository.dart';

class YouTubeProvider extends ChangeNotifier {
  final YouTubeRepository repository;
  YouTubeProvider(this.repository);

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
  String? selectedVideoId;
  int _request = 0;
  String _query = '';
  String? _nextPageToken;
  bool _trendingRequested = false;

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
      videos = [...videos, ...page.videos.where((video) => ids.add(video.id))];
      _nextPageToken = page.nextPageToken;
      hasMoreVideos = _nextPageToken != null;
    } catch (exception) {
      if (request == _request) error = exception.toString();
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
    comments = const [];
    notifyListeners();
    try {
      comments = await repository.getComments(videoId);
    } catch (exception) {
      commentsError = exception.toString();
    } finally {
      loadingComments = false;
      notifyListeners();
    }
  }
}
