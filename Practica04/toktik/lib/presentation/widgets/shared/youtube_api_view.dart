import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/youtube_video.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../screens/video_details/youtube_video_details_screen.dart';

class YouTubeApiView extends StatefulWidget {
  const YouTubeApiView({super.key});

  @override
  State<YouTubeApiView> createState() => _YouTubeApiViewState();
}

class _YouTubeApiViewState extends State<YouTubeApiView> {
  final _query = TextEditingController(text: 'videos musicales');

  void _openDetails(YouTubeVideo video, {bool autoPlay = false}) {
    final preferences = context.read<PreferencesProvider>();
    final favorite = video.toVideoPost();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => YouTubeVideoDetailsScreen(
        video: video,
        autoPlay: autoPlay,
        isFavorite: preferences.repository.isLiked(favorite),
        onFavoriteToggle: () => preferences.toggleLike(favorite),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final youtube = context.read<YouTubeProvider>();
        youtube.search(_query.text);
        youtube.loadTrendingMusic();
      }
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesProvider>();
    return Consumer<YouTubeProvider>(
    builder: (context, youtube, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          textInputAction: TextInputAction.search,
          onSubmitted: youtube.search,
          decoration: InputDecoration(
                  hintText: 'Buscar videos musicales',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () => youtube.search(_query.text),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        if (youtube.loadingVideos) const LinearProgressIndicator(),
        if (youtube.error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('No se pudieron cargar videos: ${youtube.error}'),
          ),
        for (final video in youtube.videos)
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: InkWell(
                          onTap: () => _openDetails(video, autoPlay: true),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                video.thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const ColoredBox(
                                  color: Color(0xFF30213E),
                                  child: Center(child: Icon(Icons.play_circle_outline)),
                                ),
                              ),
                              const Center(
                                child: CircleAvatar(
                                  backgroundColor: Color(0xCC000000),
                                  radius: 30,
                                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  onTap: () => _openDetails(video),
                  title: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${video.channel} · ${video.views} vistas · '
                    '${video.likes ?? 'likes ocultos'} likes',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: preferences.repository.isLiked(video.toVideoPost())
                            ? 'Quitar de favoritos'
                            : 'Agregar a favoritos',
                        icon: Icon(
                          preferences.repository.isLiked(video.toVideoPost())
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: preferences.repository.isLiked(video.toVideoPost())
                              ? const Color(0xFFFF4F9A)
                              : null,
                        ),
                        onPressed: () => preferences.toggleLike(video.toVideoPost()),
                      ),
                      IconButton(
                        tooltip: 'Ver comentarios',
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () => youtube.loadComments(video.id),
                      ),
                    ],
                  ),
                ),
                if (youtube.selectedVideoId == video.id) ...[
                  if (youtube.loadingComments)
                    const LinearProgressIndicator(),
                  if (youtube.commentsError != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No se pudieron cargar comentarios: '
                        '${youtube.commentsError}',
                      ),
                    ),
                  for (final comment in youtube.comments.take(5))
                    ListTile(
                      dense: true,
                      title: Text(comment.author),
                      subtitle: Text(
                        comment.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('♥ ${comment.likeCount}'),
                    ),
                ],
              ],
            ),
          ),
        if (youtube.loadingMoreVideos)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (youtube.hasMoreVideos)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            child: OutlinedButton.icon(
              onPressed: youtube.loadingMoreVideos
                  ? null
                  : youtube.loadMoreVideos,
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('Cargar más videos de YouTube'),
            ),
          ),
      ],
    ),
    );
  }
}
