import 'package:flutter/material.dart';

import '../../domain/entities/video_post.dart';
import '../../domain/repositories/feed_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  final FeedRepository repository;
  bool initialLoading = true;
  bool loading = false;
  bool hasMore = true;
  bool _disposed = false;
  int _generation = 0;
  int _page = 1;
  List<VideoPost> videos = [];
  List<String> unavailableSources = [];
  String? error;
  DiscoverProvider({required this.repository});
  Future<void> loadNextPage() async {
    if (loading || !hasMore) return;
    final generation = _generation;
    loading = true;
    if (!_disposed) notifyListeners();
    try {
      FeedPage result;
      if (repository is ProgressiveFeedRepository) {
        result = const FeedPage([], []);
        await for (final update
            in (repository as ProgressiveFeedRepository).loadProgressively(
              _page,
            )) {
          if (_disposed || generation != _generation) return;
          result = update;
          final ids = videos.map((v) => v.id).toSet();
          videos.addAll(update.videos.where((v) => ids.add(v.id)));
          if (videos.isNotEmpty) initialLoading = false;
          notifyListeners();
        }
      } else {
        result = await repository.load(_page);
      }
      if (_disposed || generation != _generation) return;
      unavailableSources = result.unavailableSources;
      final ids = videos.map((v) => v.id).toSet();
      videos.addAll(result.videos.where((v) => ids.add(v.id)));
      // No avanzar si la página falla por completo: permitir reintentar.
      if (result.videos.isEmpty && result.unavailableSources.isNotEmpty) {
        error = 'No se pudieron cargar los videos. Reintenta.';
      } else {
        error = null;
        hasMore = result.videos.isNotEmpty;
        _page++;
      }
    } catch (exception) {
      if (!_disposed && generation == _generation) {
        error = exception is StateError
            ? exception.message.toString()
            : 'No se pudieron cargar los videos.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        loading = false;
        initialLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> reload() async {
    _generation++;
    loading = false;
    hasMore = true;
    _page = 1;
    videos = [];
    unavailableSources = [];
    error = null;
    initialLoading = true;
    if (!_disposed) notifyListeners();
    await loadNextPage();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
