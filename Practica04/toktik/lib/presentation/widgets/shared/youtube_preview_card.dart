import 'package:flutter/material.dart';

import '../../../config/helpers/human_formats.dart';
import '../../../domain/entities/youtube_comment.dart';
import '../video/youtube_inline_player.dart';

class YouTubePreviewVideo {
  final String videoId;
  final String title;
  final String channel;
  final String url;
  final String? thumbnailUrl;
  final int? likeCount;
  final int viewCount;
  final String description;
  final String publishedAt;
  final String channelId;

  const YouTubePreviewVideo({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.url,
    this.thumbnailUrl,
    this.likeCount,
    this.viewCount = 0,
    this.description = '',
    this.publishedAt = '',
    this.channelId = '',
  });

  YouTubePreviewVideo withApiMetadata({
    required String title,
    required String channel,
    required String thumbnailUrl,
    int? likeCount,
    int? viewCount,
    String? description,
    String? publishedAt,
    String? channelId,
  }) => YouTubePreviewVideo(
    videoId: videoId,
    title: title,
    channel: channel,
    url: url,
    thumbnailUrl: thumbnailUrl,
    likeCount: likeCount,
    viewCount: viewCount ?? this.viewCount,
    description: description ?? this.description,
    publishedAt: publishedAt ?? this.publishedAt,
    channelId: channelId ?? this.channelId,
  );
}

/// YouTube watch card with inline playback and public API statistics/comments.
class YouTubePreviewCard extends StatefulWidget {
  final YouTubePreviewVideo video;
  final List<YouTubeComment> comments;
  final bool commentsLoading;
  final String? commentsError;
  final VoidCallback? onRetryComments;
  final VoidCallback? onOpenDetails;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const YouTubePreviewCard({
    super.key,
    required this.video,
    this.comments = const [],
    this.commentsLoading = false,
    this.commentsError,
    this.onRetryComments,
    this.onOpenDetails,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<YouTubePreviewCard> createState() => _YouTubePreviewCardState();
}

class _YouTubePreviewCardState extends State<YouTubePreviewCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final video = widget.video;
    final thumbnailUrl = video.thumbnailUrl?.isNotEmpty == true
        ? video.thumbnailUrl!
        : 'https://i.ytimg.com/vi/${video.videoId}/hqdefault.jpg';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _playing
                ? YouTubeInlinePlayer(
                    key: ValueKey('youtube-player-${video.videoId}'),
                    videoId: video.videoId,
                    aspectRatio: 16 / 9,
                  )
                : Semantics(
                    button: true,
                    label: 'Reproducir video de YouTube dentro de la app',
                    child: InkWell(
                      onTap: widget.onOpenDetails ?? () => setState(() => _playing = true),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : ColoredBox(
                                    color: colors.surfaceContainer,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (context, error, stackTrace) =>
                                ColoredBox(
                                  color: colors.surfaceContainer,
                                  child: Icon(
                                    Icons.ondemand_video,
                                    size: 48,
                                    color: colors.primary,
                                  ),
                                ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .92),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(13),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .68),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  'Reproducir aquí',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: widget.onOpenDetails ?? () => setState(() => _playing = true),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 18, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        video.channel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: widget.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                      onPressed: widget.onFavoriteToggle,
                      icon: Icon(
                        widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: widget.isFavorite ? const Color(0xFFFF4F9A) : colors.primary,
                      ),
                    ),
                    Icon(Icons.thumb_up_alt_outlined, size: 18, color: colors.primary),
                    const SizedBox(width: 5),
                    Text(
                      video.likeCount == null
                          ? 'Ocultos'
                          : HumanFormats.humanReadbleNumber(
                              video.likeCount!.toDouble(),
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _playing = true),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Reproducir aquí'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.forum_outlined, size: 19, color: colors.primary),
                    const SizedBox(width: 7),
                    Text(
                      'Comentarios públicos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (widget.commentsLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(color: colors.primary),
                  )
                else if (widget.commentsError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commentsError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: .72),
                          ),
                        ),
                        if (widget.onRetryComments != null)
                          TextButton.icon(
                            onPressed: widget.onRetryComments,
                            icon: const Icon(Icons.refresh_rounded, size: 17),
                            label: const Text('Reintentar'),
                          ),
                      ],
                    ),
                  )
                else if (widget.comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      'No hay comentarios públicos disponibles.',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                else
                  ...widget.comments.take(5).map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: colors.primary.withValues(alpha: .12),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (comment.likeCount > 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.favorite_border,
                              size: 14,
                              color: colors.onSurface.withValues(alpha: .60),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${comment.likeCount}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
