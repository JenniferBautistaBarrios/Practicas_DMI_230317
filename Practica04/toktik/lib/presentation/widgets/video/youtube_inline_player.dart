import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class YouTubeInlinePlayer extends StatefulWidget {
  final String videoId;
  final bool muted;
  final double aspectRatio;
  final bool autoPlay;
  final String? thumbnailUrl;
  final VoidCallback? onUnavailable;

  const YouTubeInlinePlayer({
    super.key,
    required this.videoId,
    this.muted = false,
    this.aspectRatio = 9 / 16,
    this.autoPlay = true,
    this.thumbnailUrl,
    this.onUnavailable,
  });

  @override
  State<YouTubeInlinePlayer> createState() => _YouTubeInlinePlayerState();
}

class _YouTubeInlinePlayerState extends State<YouTubeInlinePlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  Timer? _skipUnavailableTimer;
  int? _playerError;
  bool _unavailableReported = false;

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
        autoPlay: widget.autoPlay,
        params: YoutubePlayerParams(
          mute: widget.muted,
          // The feed controls playback with autoplay and Flutter actions;
          // let vertical gestures reach the surrounding PageView.
          showControls: false,
          pointerEvents: PointerEvents.none,
          showFullscreenButton: false,
          interfaceLanguage: 'es',
          playsInline: true,
          // A web embed needs its real hosting origin. On native platforms the
          // player runs in a WebView, so do not claim youtube.com as the app's
          // origin; that mismatch can make YouTube reject the embed.
          origin: kIsWeb ? Uri.base.origin : null,
          // Use youtube.com for anonymous playback. The no-cookie embed can
          // fail to initialize some public Shorts in embedded WebViews.
          privacyEnhancedMode: false,
        ),
      );
      _playerSubscription = _controller!.stream.listen((value) {
        if (!value.hasError || !mounted) return;
        final code = value.error.code;
        final onUnavailable = widget.onUnavailable;
        if (onUnavailable != null) {
          if (_unavailableReported) return;
          _unavailableReported = true;
          // Skip unavailable feed items before showing the playback error.
          _skipUnavailableTimer = Timer(const Duration(milliseconds: 120), () {
            if (mounted) onUnavailable();
          });
          return;
        }
        setState(() => _playerError = code);
      });
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
    _skipUnavailableTimer?.cancel();
    _playerSubscription?.cancel();
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
    final errorCode = _playerError;
    return Center(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            YoutubePlayer(
              controller: controller,
              aspectRatio: widget.aspectRatio,
              backgroundColor: Colors.black,
          // Vertical drags navigate the feed, not player fullscreen.
              enableFullScreenOnVerticalDrag: false,
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
            ),
            if (errorCode != null)
              ColoredBox(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.thumbnailUrl != null)
                      Image.network(
                        widget.thumbnailUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black87,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage(errorCode),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => launchUrl(
                                  Uri.https('www.youtube.com', '/watch', {'v': widget.videoId}),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Ver en YouTube'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(int code) => switch (code) {
    100 => 'YouTube no encuentra este video o ya no es público. (Error 100)',
    101 || 150 || 152 => 'El propietario no permite reproducir este video dentro de otras apps. (Error $code)',
    153 => 'YouTube rechazó el reproductor integrado de esta app. (Error 153)',
    _ => 'YouTube no pudo reproducir este video. (Error $code)',
  };
}
