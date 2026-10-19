import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/helpers/human_formats.dart';
import '../../../domain/entities/youtube_video.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/youtube_provider.dart';
import '../video/youtube_inline_player.dart';

/// Full-screen landscape feed of embeddable YouTube videos.
class YouTubeApiView extends StatefulWidget {
  const YouTubeApiView({super.key});

  @override
  State<YouTubeApiView> createState() => _YouTubeApiViewState();
}

class _YouTubeApiViewState extends State<YouTubeApiView> {
  static const _videoCount = 50;
  final _pages = PageController();
  int _active = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<YouTubeProvider>().loadEmbeddableVideos(
          limit: _videoCount,
        );
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _skipUnavailable(YouTubeVideo video, int oldIndex) async {
    final youtube = context.read<YouTubeProvider>();
    await youtube.skipUnavailableVideo(video.id);
    _moveToNextAvailable(oldIndex, youtube);
  }

  void _moveToNextAvailable(int oldIndex, YouTubeProvider youtube) {
    if (!mounted || youtube.videos.isEmpty || !_pages.hasClients) return;
    final nextIndex = oldIndex.clamp(0, youtube.videos.length - 1).toInt();
    _pages.jumpToPage(nextIndex);
    setState(() => _active = nextIndex);
  }

  Future<void> _showNext(YouTubeProvider youtube) async {
    if (_active + 1 < youtube.videos.length && _pages.hasClients) {
      _pages.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else if (youtube.hasMoreVideos && !youtube.loadingMoreVideos) {
      await youtube.loadMoreVideos();
      if (mounted && _active + 1 < youtube.videos.length && _pages.hasClients) {
        _pages.nextPage(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<void> _showComments(YouTubeVideo video) async {
    final youtube = context.read<YouTubeProvider>();
    youtube.loadComments(video.id);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171717),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .68,
          child: Consumer<YouTubeProvider>(
            builder: (context, state, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Comentarios de YouTube',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.loadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : state.commentsError != null
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            state.commentsReason == 'commentsDisabled'
                                ? 'El creador desactivó los comentarios de este video.'
                                : state.commentsApiMessage ??
                                    state.commentsError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : state.comments.isEmpty
                      ? const Center(
                          child: Text(
                            'Este video no tiene comentarios públicos.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.comments.length,
                          itemBuilder: (context, commentIndex) {
                            final comment = state.comments[commentIndex];
                            return ListTile(
                              title: Text(
                                comment.author,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                comment.text,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: comment.likeCount == 0
                                  ? null
                                  : Text(
                                      '♥ ${comment.likeCount}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer2<YouTubeProvider, PreferencesProvider>(
    builder: (context, youtube, preferences, _) {
      if (youtube.loadingVideos && youtube.videos.isEmpty) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Buscando videos de YouTube…',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
      if (youtube.videos.isEmpty) {
        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.smart_display_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    youtube.error ?? 'No se pudieron cargar los videos.',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => youtube.loadEmbeddableVideos(
                      limit: _videoCount,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final videos = youtube.videos;
      return LayoutBuilder(
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pages,
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                onPageChanged: (index) {
                  setState(() => _active = index);
                  if (index >= videos.length - 5) {
                    youtube.loadMoreVideos();
                  }
                },
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final favorite = video.toVideoPost();
                  return _FullScreenVideoPage(
                    key: ValueKey(video.id),
                    video: video,
                    active: index == _active,
                    showNext: index + 1 < videos.length ||
                        youtube.hasMoreVideos,
                    onNext: () => _showNext(youtube),
                    isSaved: preferences.repository.isLiked(favorite),
                    onSave: () => preferences.toggleLike(favorite),
                    onComments: () => _showComments(video),
                    onUnavailable: () => _skipUnavailable(video, index),
                  );
                },
              ),
              if (youtube.loadingMoreVideos)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (youtube.error != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        youtube.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

class _FullScreenVideoPage extends StatelessWidget {
  final YouTubeVideo video;
  final bool active;
  final bool showNext;
  final bool isSaved;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final VoidCallback onComments;
  final VoidCallback onUnavailable;

  const _FullScreenVideoPage({
    super.key,
    required this.video,
    required this.active,
    required this.showNext,
    required this.isSaved,
    required this.onNext,
    required this.onSave,
    required this.onComments,
    required this.onUnavailable,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (active)
          ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const aspectRatio = 9 / 16;
                final width = constraints.maxWidth >
                        constraints.maxHeight * aspectRatio
                    ? constraints.maxWidth
                    : constraints.maxHeight * aspectRatio;
                final height = width / aspectRatio;
                return OverflowBox(
                  minWidth: width,
                  maxWidth: width,
                  minHeight: height,
                  maxHeight: height,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: YouTubeInlinePlayer(
                      videoId: video.id,
                      aspectRatio: aspectRatio,
                      autoPlay: true,
                      muted: true,
                      thumbnailUrl: video.thumbnailUrl,
                      onUnavailable: onUnavailable,
                    ),
                  ),
                );
              },
            ),
          )
        else
          Image.network(
            video.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        Positioned(
          left: 16,
          right: 76,
          bottom: 14,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .48),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  video.channel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isSaved ? 'Quitar de Me gusta' : 'Me gusta',
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border,
                  color: isSaved ? const Color(0xFFFF4F81) : Colors.white,
                ),
              ),
              Text(
                video.likes == null
                    ? 'Me gusta'
                    : HumanFormats.humanReadbleNumber(
                        video.likes!.toDouble(),
                      ),
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              IconButton(
                tooltip: 'Comentarios',
                onPressed: onComments,
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Comentarios',
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
              Text(
                HumanFormats.humanReadbleNumber(video.views.toDouble()),
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              if (showNext)
                IconButton.filledTonal(
                  tooltip: 'Siguiente video',
                  onPressed: onNext,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: .48),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
