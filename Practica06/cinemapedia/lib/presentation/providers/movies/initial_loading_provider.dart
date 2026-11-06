import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movies_providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  final step1 = ref.watch(nowPlayingMoviesProvider).isLoading;
  final step2 = ref.watch(popularMoviesProvider).isLoading;
  final step3 = ref.watch(topRatedMoviesProvider).isLoading;
  final step4 = ref.watch(upcomingMoviesProvider).isLoading;

  if (step1 || step2 || step3 || step4) return true;

  return false; // terminamos de cargar
});
