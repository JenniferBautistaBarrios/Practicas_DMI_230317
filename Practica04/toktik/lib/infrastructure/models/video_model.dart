class VideoModel {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String description;
  final String publishedAt;
  final String channelId;
  final int viewCount;
  final int? likeCount;

  const VideoModel({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    this.description = '',
    this.publishedAt = '',
    this.channelId = '',
    required this.viewCount,
    required this.likeCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final thumbnail = thumbnails['maxres'] as Map<String, dynamic>? ??
        thumbnails['high'] as Map<String, dynamic>? ??
        thumbnails['medium'] as Map<String, dynamic>? ??
        thumbnails['default'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    return VideoModel(
      id: json['id'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      channelTitle: snippet['channelTitle'] as String? ?? '',
      thumbnailUrl: thumbnail['url'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      publishedAt: snippet['publishedAt'] as String? ?? '',
      channelId: snippet['channelId'] as String? ?? '',
      viewCount: int.tryParse('${statistics['viewCount'] ?? 0}') ?? 0,
      likeCount: int.tryParse('${statistics['likeCount'] ?? ''}'),
    );
  }
}

class VideoModelPage {
  final List<VideoModel> videos;
  final String? nextPageToken;

  const VideoModelPage({required this.videos, this.nextPageToken});
}
