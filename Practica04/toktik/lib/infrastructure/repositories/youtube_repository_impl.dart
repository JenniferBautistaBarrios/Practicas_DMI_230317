import '../../domain/entities/youtube_comment.dart';
import '../../domain/entities/youtube_video.dart';
import '../../domain/repositories/youtube_repository.dart';
import '../datasources/youtube_video_datasource.dart';
import '../models/video_model.dart';

class YouTubeRepositoryImpl
    implements YouTubeRepository, PagedYouTubeRepository, TrendingYouTubeRepository, YouTubeVideosByIdsRepository {
  final YouTubeVideoDatasource datasource;

  const YouTubeRepositoryImpl(this.datasource);

  @override
  Future<List<YouTubeVideo>> getTrendingMusicVideos({int limit = 20}) async =>
      (await datasource.getTrendingVideos(categoryId: '10', maxResults: limit))
          .map(_asYouTubeVideo)
          .toList();

  @override
  Future<List<YouTubeVideo>> getVideosByIds(Iterable<String> videoIds) async {
    final ids = videoIds.toList();
    final videos = await datasource.getVideosByIds(ids);
    final byId = {for (final video in videos) video.id: _asYouTubeVideo(video)};
    return [for (final id in ids) if (byId.containsKey(id)) byId[id]!];
  }

  @override
  Future<List<YouTubeVideo>> searchVideos(String query, {int limit = 20}) async {
    final page = await searchVideosPage(query, limit: limit);
    return page.videos;
  }

  @override
  Future<YouTubeVideoPage> searchVideosPage(
    String query, {
    int limit = 20,
    String? pageToken,
  }) async {
    final result = await datasource.searchVideosPage(
      term: query,
      maxResults: limit,
      pageToken: pageToken,
    );
    final videos = result.videos.map(_asYouTubeVideo).toList();
    return YouTubeVideoPage(
      videos: videos,
      nextPageToken: result.nextPageToken,
    );
  }

  YouTubeVideo _asYouTubeVideo(VideoModel video) => YouTubeVideo(
    id: video.id,
    title: video.title,
    channel: video.channelTitle,
    thumbnailUrl: video.thumbnailUrl,
    description: video.description,
    publishedAt: video.publishedAt,
    channelId: video.channelId,
    views: video.viewCount,
    likes: video.likeCount,
  );

  @override
  Future<List<YouTubeComment>> getComments(
    String videoId, {
    int limit = 20,
  }) async => (await datasource.getCommentsByVideoId(
    videoId,
    maxResults: limit,
  )).map((comment) => comment.toEntity()).toList();
}
