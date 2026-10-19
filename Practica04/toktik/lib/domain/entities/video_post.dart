enum VideoSource {
  local,
  youtube,
  vimeo,
  dailymotion,
  pexels,
  pixabay,
  internetArchive,
  wikimedia,
  peertube,
  googleDrive,
}

class VideoPost {
  final String caption;
  final String videoUrl;
  final int likes;
  final int views;
  final VideoSource source;
  final String? externalId;
  final String? thumbnailUrl;
  final String description;
  final String? attributionUrl;
  final String? licenseUrl;
  bool get supportsDirectPlayback =>
      source == VideoSource.local ||
      source == VideoSource.youtube ||
      source == VideoSource.pexels ||
      source == VideoSource.pixabay ||
      source == VideoSource.wikimedia ||
      source == VideoSource.peertube ||
      source == VideoSource.googleDrive ||
      source == VideoSource.internetArchive;
  const VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.source = VideoSource.local,
    this.externalId,
    this.thumbnailUrl,
    this.description = '',
    this.attributionUrl,
    this.licenseUrl,
  });
  String get id => '${source.name}:${externalId ?? videoUrl}';
  Map<String, dynamic> toJson() => {
    'caption': caption,
    'videoUrl': videoUrl,
    'likes': likes,
    'views': views,
    'source': source.name,
    'externalId': externalId,
    'thumbnailUrl': thumbnailUrl,
    'description': description,
    'attributionUrl': attributionUrl,
    'licenseUrl': licenseUrl,
  };
  factory VideoPost.fromJson(Map<String, dynamic> json) => VideoPost(
    caption: json['caption'] as String,
    videoUrl: json['videoUrl'] as String,
    likes: json['likes'] as int? ?? 0,
    views: json['views'] as int? ?? 0,
    source: VideoSource.values.firstWhere(
      (s) => s.name == json['source'],
      orElse: () => VideoSource.local,
    ),
    externalId: json['externalId'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    description: json['description'] as String? ?? '',
    attributionUrl: json['attributionUrl'] as String?,
    licenseUrl: json['licenseUrl'] as String?,
  );
}
