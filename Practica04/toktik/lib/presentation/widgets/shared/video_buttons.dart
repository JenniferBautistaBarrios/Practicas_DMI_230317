import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/helpers/human_formats.dart';
import '../../../domain/entities/video_post.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/youtube_provider.dart';

class VideoButtons extends StatefulWidget {
  final VideoPost video;
  const VideoButtons({super.key, required this.video});

  @override
  State<VideoButtons> createState() => _VideoButtonsState();
}

class _VideoButtonsState extends State<VideoButtons> {
  bool _saved = false;

  void _openComments(BuildContext context) {
    final video = widget.video;
    final youtube = video.source == VideoSource.youtube
        ? context.read<YouTubeProvider>()
        : null;
    final videoId = video.externalId;
    if (youtube != null && videoId != null) {
      youtube.loadComments(videoId);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CommentsSheet(
        video: video,
        youtube: youtube,
        videoId: videoId,
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar el cambio. Inténtalo de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final liked = prefs.repository.isLiked(widget.video);
    final likeCount = prefs.repository.likes(widget.video);
    final muted = prefs.repository.muted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: liked ? 'Quitar Me gusta' : 'Dar Me gusta',
          onPressed: () => _save(context, () => prefs.toggleLike(widget.video)),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: .36),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .28)),
          ),
          icon: Badge(
            isLabelVisible: liked,
            alignment: AlignmentDirectional.topEnd,
            label: Text(
              likeCount >= 1000
                  ? HumanFormats.humanReadbleNumber(likeCount.toDouble())
                  : '$likeCount',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            child: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              size: 34,
              color: liked ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
          ),
        ),
        Semantics(
          label: '$likeCount Me gusta',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Container(
              key: ValueKey(likeCount),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: liked
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: .67)
                    : Colors.black.withValues(alpha: .28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                likeCount >= 1000
                    ? HumanFormats.humanReadbleNumber(likeCount.toDouble())
                    : likeCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        IconButton(
          tooltip: 'Comentarios',
          onPressed: () => _openComments(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: .36),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .28)),
          ),
          icon: const Icon(Icons.mode_comment_outlined, size: 28),
        ),
        const SizedBox(height: 10),
        IconButton(
          tooltip: _saved ? 'Guardado' : 'Guardar',
          onPressed: () => setState(() => _saved = !_saved),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: .36),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .28)),
          ),
          icon: Icon(
            _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 30,
            color: _saved ? Theme.of(context).colorScheme.primary : Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Icon(Icons.visibility_outlined, color: Colors.white),
        Text(
          HumanFormats.humanReadbleNumber(widget.video.views.toDouble()),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        IconButton(
          tooltip: muted ? 'Activar sonido' : 'Silenciar',
          onPressed: () => _save(context, prefs.toggleMuted),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: .36),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .28)),
          ),
          icon: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }
}

class _CommentsSheet extends StatelessWidget {
  final VideoPost video;
  final YouTubeProvider? youtube;
  final String? videoId;

  const _CommentsSheet({
    required this.video,
    required this.youtube,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      heightFactor: .72,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: .24),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comentarios',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        video.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar comentarios',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Expanded(child: _buildComments(context)),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    final provider = youtube;
    if (provider == null || videoId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Los comentarios aún no están disponibles para este video.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.loadingComments && provider.selectedVideoId == videoId) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.commentsError != null &&
            provider.selectedVideoId == videoId) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.forum_outlined, size: 38),
                  const SizedBox(height: 10),
                  Text(
                    provider.commentsError!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => provider.loadComments(videoId!),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (provider.selectedVideoId != videoId || provider.comments.isEmpty) {
          return const Center(child: Text('Este video aún no tiene comentarios.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: provider.comments.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 68),
          itemBuilder: (context, index) {
            final comment = provider.comments[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person_outline_rounded),
              ),
              title: Text(comment.author),
              subtitle: Text(comment.text),
              trailing: comment.likeCount > 0
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_border, size: 15),
                        const SizedBox(width: 4),
                        Text('${comment.likeCount}'),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
