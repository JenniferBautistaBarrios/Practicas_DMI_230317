import 'package:toktik/domain/entities/video_post.dart';

class LocalVideoModel {
  final String name;
  final String description;
  final String videoUrl;
  final int likes;
  final int views;

  LocalVideoModel({
    required this.name,
    this.description = '',
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        name: json['name'] ?? 'No name',
        description: json['description'] ?? '',
        videoUrl: json['videoUrl'],
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
      );

  VideoPost toVideoPostEntity() => VideoPost(
    caption: name,
    description: description.isNotEmpty
        ? description
        : "$name · Un momento que merece la pena compartir. #ParaTi",
    videoUrl: videoUrl,
    likes: likes,
    views: views,
  );
}
