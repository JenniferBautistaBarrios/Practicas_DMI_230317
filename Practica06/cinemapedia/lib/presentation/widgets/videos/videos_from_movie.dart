import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


final FutureProviderFamily<List<Video>, int> videosFromMovieProvider = FutureProvider.family((ref, int movieId) {
  final movieRepository = ref.watch(movieRepositoryProvider);
  return movieRepository.getYoutubeVideosById(movieId);
});

class VideosFromMovie extends ConsumerWidget {

  final int movieId;

  const VideosFromMovie({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {
    final moviesFromVideo = ref.watch(videosFromMovieProvider(movieId));

    return moviesFromVideo.when(
      data: ( videos ) => _VideosList( videos: videos ),
      error: (_ , __) => Center(child: Text(AppStrings.of(context).videosError) ), 
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _VideosList extends StatelessWidget {

  final List<Video> videos;

  const _VideosList({required this.videos });

  @override
  Widget build(BuildContext context) {

    //* Nada que mostrar
    if ( videos.isEmpty ) {
      return const SizedBox(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ignore: prefer_const_constructors
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(AppStrings.of(context).videos, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        
        //* Aunque tengo varios videos, sólo quiero mostrar el primero
        _YouTubeVideoPlayer(youtubeId: videos.first.youtubeKey, name: videos.first.name )
        
        //* Si se desean mostrar todos los videos
        // ...videos.map(
        //   (video) => _YouTubeVideoPlayer(youtubeId: videos.first.youtubeKey, name: video.name)
        // ).toList()
      ],
    );
  }
}

class _YouTubeVideoPlayer extends StatefulWidget {

  final String youtubeId;
  final String name;

  const _YouTubeVideoPlayer({ required this.youtubeId, required this.name });

  @override
  State<_YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<_YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: false,
        enableCaption: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name),
          YoutubePlayer(controller: _controller)
        ],
      )
    );
  }
}