import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'actors_repository_provider.dart';

final actorsByMovieProvider = FutureProvider.autoDispose.family((
  ref,
  String movieId,
) {
  return ref.watch(actorsRepositoryProvider).getActorsByMovie(movieId);
});
