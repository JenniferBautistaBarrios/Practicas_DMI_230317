import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movies_repository_provider.dart';

final movieInfoProvider = FutureProvider.autoDispose.family((
  ref,
  String movieId,
) {
  return ref.watch(movieRepositoryProvider).getMovieById(movieId);
});

// Shared by carousel, lists and details. A country change invalidates the cache.
final movieCertificationProvider = FutureProvider.family((ref, String movieId) {
  return ref.watch(movieRepositoryProvider).getCertification(movieId);
});
