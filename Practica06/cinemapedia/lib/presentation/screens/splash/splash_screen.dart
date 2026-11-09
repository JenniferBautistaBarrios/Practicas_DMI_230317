import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';

/// Pantalla de carga inicial al estilo de las apps de streaming:
/// fondo negro, la "C" se dibuja, aparece el nombre y luego hace zoom
/// hacia la pantalla principal.
class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _draw;
  late final Animation<double> _popIn;
  late final Animation<double> _zoom;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _draw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _popIn = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    ));
    _zoom = Tween<double>(begin: 1.0, end: 14.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeInCubic),
    ));
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      context.go('/home/0');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _fadeOut.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _popIn.value,
                      child: CinemapediaLogo(size: 130, progress: _draw.value),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
