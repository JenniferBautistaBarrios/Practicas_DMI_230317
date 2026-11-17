import 'dart:math' as math;

import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drop;
  late final Animation<double> _fadeIn;
  late final Animation<double> _exit;

  @override
  void initState() {
    super.initState();
    _loadCatalog();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    // El logo cae desde arriba y rebota
    _drop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.bounceOut),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
    );
    // Al final se encoge y desaparece
    _exit = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    _controller.forward().whenComplete(() {
      if (mounted) context.go('/home/0');
    });
  }

  void _loadCatalog() {
    final isSeries = ref.read(catalogTypeProvider) == CatalogType.series;
    final providers = isSeries
        ? [
            onTheAirSeriesProvider,
            airingTodaySeriesProvider,
            popularSeriesProvider,
            topRatedSeriesProvider,
          ]
        : [
            nowPlayingMoviesProvider,
            upcomingMoviesProvider,
            popularMoviesProvider,
            topRatedMoviesProvider,
          ];

    for (final provider in providers) {
      if (ref.read(provider).isEmpty) {
        ref.read(provider.notifier).loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Onda rosa que se expande detrás del logo (0 = no visible).
  Widget _ring(double progress, Color color) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();

    final size = 130 + 190 * progress;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.35 * (1 - progress)),
          width: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;

            final dropY = (1 - _drop.value) * -180;
            final opacity = _fadeIn.value * (1 - _exit.value);
            final scale = 1.0 - 0.5 * _exit.value;

            // Pequeño balanceo mientras las ondas se expanden
            final wobble = (t > 0.4 && t < 0.8)
                ? 0.07 * math.sin(((t - 0.4) / 0.4) * 2 * math.pi * 2)
                : 0.0;

            final ring1 = ((t - 0.35) / 0.4).clamp(0.0, 1.0);
            final ring2 = ((t - 0.5) / 0.4).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _ring(ring1, color),
                  _ring(ring2, color),
                  Transform.translate(
                    offset: Offset(0, dropY),
                    child: Transform.rotate(
                      angle: wobble,
                      child: Transform.scale(
                        scale: scale,
                        child: const CinemapediaLogo(size: 130),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
