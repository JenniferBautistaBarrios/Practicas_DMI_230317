import 'package:flutter/material.dart';

import '../../../config/helpers/human_formats.dart';
import '../../../domain/entities/video_post.dart';
import '../video/youtube_inline_player.dart';

/// Lightweight YouTube results: show metadata and thumbnails without starting
/// an embedded player for every result.
class YouTubeVideoListView extends StatelessWidget {
  final List<VideoPost> videos;

  const YouTubeVideoListView({super.key, required this.videos});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.fromLTRB(
      12,
      MediaQuery.paddingOf(context).top + 68,
      12,
      MediaQuery.paddingOf(context).bottom + 20,
    ),
    itemCount: videos.length,
    separatorBuilder: (context, index) => const SizedBox(height: 14),
    itemBuilder: (context, index) => _YouTubeVideoCard(video: videos[index]),
  );
}

class _YouTubeVideoCard extends StatefulWidget {
  final VideoPost video;

  const _YouTubeVideoCard({required this.video});

  @override
  State<_YouTubeVideoCard> createState() => _YouTubeVideoCardState();
}

class _YouTubeVideoCardState extends State<_YouTubeVideoCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final thumbnail = video.thumbnailUrl;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _playing && video.externalId != null
                ? YouTubeInlinePlayer(
                    key: ValueKey('list-player-${video.id}'),
                    videoId: video.externalId!,
                    aspectRatio: 16 / 9,
                  )
                : InkWell(
                    onTap: video.externalId == null
                        ? null
                        : () => setState(() => _playing = true),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        thumbnail == null || thumbnail.isEmpty
                ? _fallbackThumbnail(video.externalId)
                : Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackThumbnail(video.externalId),
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const _ThumbnailPlaceholder(),
                  ),
                        if (video.externalId != null)
                          const Center(
                            child: CircleAvatar(
                              backgroundColor: Color(0xCC000000),
                              radius: 29,
                              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFFFE3EF),
                  child: Icon(Icons.play_arrow_rounded, color: Color(0xFFE91E83)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${video.description} | ${HumanFormats.humanReadbleNumber(video.views.toDouble())} vistas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

Widget _fallbackThumbnail(String? videoId) {
  if (videoId == null || videoId.isEmpty) return const _ThumbnailPlaceholder();
  return Image.network(
    'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
    fit: BoxFit.cover,
    filterQuality: FilterQuality.low,
    errorBuilder: (context, error, stackTrace) => const _ThumbnailPlaceholder(),
    loadingBuilder: (context, child, progress) =>
        progress == null ? child : const _ThumbnailPlaceholder(),
  );
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFEADFE5),
    child: Center(child: Icon(Icons.image_outlined, size: 36)),
  );
}
