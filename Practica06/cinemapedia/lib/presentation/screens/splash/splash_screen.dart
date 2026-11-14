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
  late final Animation<double> _popIn;
  late final Animation<double> _zoom;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _loadCatalog();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _fadeOut.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: Transform.scale(
                  scale: _popIn.value,
                  child: const CinemapediaLogo(size: 130),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
