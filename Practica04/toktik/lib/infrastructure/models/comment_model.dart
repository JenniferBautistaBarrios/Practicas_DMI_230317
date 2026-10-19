import '../../domain/entities/youtube_comment.dart';

class CommentModel {
  final String author;
  final String text;
  final int likeCount;

  const CommentModel({
    required this.author,
    required this.text,
    required this.likeCount,
  });

  factory CommentModel.fromThreadJson(Map<String, dynamic> json) {
    final thread = json['snippet'] as Map<String, dynamic>? ?? {};
    final top = thread['topLevelComment'] as Map<String, dynamic>? ?? {};
    final snippet = top['snippet'] as Map<String, dynamic>? ?? {};
    return CommentModel(
      author: snippet['authorDisplayName'] as String? ?? 'Usuario de YouTube',
      text: snippet['textOriginal'] as String? ??
          snippet['textDisplay'] as String? ??
          '',
      likeCount: int.tryParse('${snippet['likeCount'] ?? 0}') ?? 0,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    author: json['author'] as String? ?? 'Usuario de YouTube',
    text: json['text'] as String? ?? '',
    likeCount: int.tryParse('${json['likeCount'] ?? 0}') ?? 0,
  );

  YouTubeComment toEntity() => YouTubeComment(
    author: author,
    text: text,
    likeCount: likeCount,
  );
}
