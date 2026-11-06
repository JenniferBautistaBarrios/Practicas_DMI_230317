import 'package:cinemapedia/infraestructure/datasources/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infraestructure/repositories/actor_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../movies/movie_country_provider.dart';

import 'package:cinemapedia/domain/repositories/actors_repository.dart';

final actorsRepositoryProvider = Provider<ActorsRepository>((ref) {
  return ActorRepositoryImpl(
    ActorMovieDbDatasource(language: ref.watch(movieCountryProvider).language),
  );
});
