import 'package:flutter/material.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {

  final String videoUrl;
  final String caption;
  final bool isActive;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    required this.isActive,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {

  late VideoPlayerController controller;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();

    final uri = Uri.tryParse(widget.videoUrl);
    controller = uri != null && (uri.scheme == 'https' || uri.scheme == 'http')
        ? VideoPlayerController.networkUrl(uri)
        : VideoPlayerController.asset(widget.videoUrl);
    _initialization = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await controller.initialize();
    if (!mounted) return;

    await controller.setVolume(1.0);
    await controller.setLooping(true);
    if (widget.isActive) {
      await controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && controller.value.isInitialized) {
      if (widget.isActive) {
        controller.play();
      } else {
        controller.pause();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No se pudo cargar el video. Revisa el enlace y sus permisos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if ( snapshot.connectionState != ConnectionState.done ){
          return const Center( child: CircularProgressIndicator( strokeWidth: 2 ));
        }

        return GestureDetector(
          onTap: () {
            if ( controller.value.isPlaying ) {
              controller.pause();
              return;
            }
            controller.play();
            
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              children: [
        
                VideoPlayer(controller),
        
                // Gradiente
                VideoBackground(
                  stops: const [0.8,1.0],
                ),
        
                // Texto
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: _VideoCaption( caption: widget.caption )
                ),
        
        
              ],
            ),
          ),
        );

      },
    );
  }
}


class _VideoCaption extends StatelessWidget {

  final String caption;


  const _VideoCaption({required this.caption });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: size.width * 0.6,
      child: Text( caption, maxLines: 2, style: titleStyle ),
    );
  }
}
