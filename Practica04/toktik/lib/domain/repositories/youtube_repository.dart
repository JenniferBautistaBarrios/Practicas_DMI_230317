import '../entities/youtube_comment.dart';
import '../entities/youtube_video.dart';

abstract class YouTubeRepository {
  Future<List<YouTubeVideo>> searchVideos(String query, {int limit = 20});
  Future<List<YouTubeComment>> getComments(String videoId, {int limit = 20});
}

abstract class PagedYouTubeRepository {
  Future<YouTubeVideoPage> searchVideosPage(
    String query, {
    int limit = 20,
    String? pageToken,
  });
}

abstract class TrendingYouTubeRepository {
  Future<List<YouTubeVideo>> getTrendingMusicVideos({int limit = 20});
}

abstract class YouTubeVideosByIdsRepository {
  Future<List<YouTubeVideo>> getVideosByIds(Iterable<String> videoIds);
}
