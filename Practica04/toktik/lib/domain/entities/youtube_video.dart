import 'video_post.dart';

class YouTubeVideo {
  final String id;
  final String title;
  final String channel;
  final String thumbnailUrl;
  final String description;
  final String publishedAt;
  final String channelId;
  final int views;
  final int? likes;

  const YouTubeVideo({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    this.description = '',
    this.publishedAt = '',
    this.channelId = '',
    required this.views,
    required this.likes,
  });

  String get url => 'https://www.youtube.com/watch?v=$id';

  VideoPost toVideoPost() => VideoPost(
    caption: title,
    videoUrl: url,
    likes: likes ?? 0,
    views: views,
    source: VideoSource.youtube,
    externalId: id,
    thumbnailUrl: thumbnailUrl,
    description: description.isNotEmpty ? description : channel,
    attributionUrl: url,
  );
}

class YouTubeVideoPage {
  final List<YouTubeVideo> videos;
  final String? nextPageToken;

  const YouTubeVideoPage({required this.videos, this.nextPageToken});
}
