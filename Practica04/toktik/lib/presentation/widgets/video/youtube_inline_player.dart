import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeInlinePlayer extends StatefulWidget {
  final String videoId;
  final bool muted;
  final double aspectRatio;

  const YouTubeInlinePlayer({
    super.key,
    required this.videoId,
    this.muted = false,
    this.aspectRatio = 9 / 16,
  });

  @override
  State<YouTubeInlinePlayer> createState() => _YouTubeInlinePlayerState();
}

class _YouTubeInlinePlayerState extends State<YouTubeInlinePlayer> {
  YoutubePlayerController? _controller;

  bool get _supportedPlatform => kIsWeb || switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();
    if (_supportedPlatform) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: YoutubePlayerParams(
          mute: widget.muted,
          showControls: true,
          showFullscreenButton: true,
          interfaceLanguage: 'es',
          playsInline: true,
          privacyEnhancedMode: true,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant YouTubeInlinePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && oldWidget.muted != widget.muted) {
      if (widget.muted) {
        _controller!.mute();
      } else {
        _controller!.unMute();
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.smart_display_rounded, color: Colors.white, size: 38),
                const SizedBox(height: 8),
                const Text('Este dispositivo no admite el reproductor integrado.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Abrir en YouTube'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Center(
      child: YoutubePlayer(
        controller: controller,
        aspectRatio: widget.aspectRatio,
        backgroundColor: Colors.black,
      ),
    );
  }
}
