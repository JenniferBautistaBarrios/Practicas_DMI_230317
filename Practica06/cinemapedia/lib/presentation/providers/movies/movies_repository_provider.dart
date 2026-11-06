import 'package:cinemapedia/infraestructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infraestructure/repositories/movie_repository_impl.dart';

import 'movie_country_provider.dart';

import 'package:cinemapedia/domain/repositories/movies_repository.dart';

// Rebuild repositories and dependent caches whenever the selected country changes.
final movieRepositoryProvider = Provider<MoviesRepository>((ref) {
  return MovieRepositoryImpl(
    MoviedbDatasource(country: ref.watch(movieCountryProvider)),
  );
});
