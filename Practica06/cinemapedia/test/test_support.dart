import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';

Movie sampleMovie(int id, {String title = 'Película de prueba'}) => Movie(
  adult: false,
  backdropPath: 'https://example.com/backdrop.jpg',
  genreIds: [],
  id: id,
  originalLanguage: 'es',
  originalTitle: 'Original',
  overview: 'Sinopsis',
  popularity: 20,
  posterPath: 'https://example.com/poster.jpg',
  releaseDate: DateTime(2026, 11, 3),
  title: title,
  video: false,
  voteAverage: 8.0,
  voteCount: 100,
);

class FakeMoviesRepository extends MoviesRepository {
  final MovieCountry country;
  final bool fail;
  final bool empty;
  FakeMoviesRepository(this.country, {this.fail = false, this.empty = false});
  List<Movie> get movies => empty
      ? []
      : List.generate(
          3,
          (index) => sampleMovie(
            index + 1,
            title: '${country.code} película ${index + 1}',
          ),
        );
  Future<List<Movie>> _get(int page) async {
    if (fail) throw Exception('Offline');
    return page == 1 ? movies : [];
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) => _get(page);
  @override
  Future<List<Movie>> getPopular({int page = 1}) => _get(page);
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) => _get(page);
  @override
  Future<List<Movie>> getTopRated({int page = 1}) => _get(page);
  @override
  Future<Movie> getMovieById(String id) async => movies.first;
  @override
  Future<List<Movie>> searchMovies(String query) async => movies;
  @override
  Future<String?> getCertification(String movieId) async =>
      country == MovieCountry.mexico
      ? 'B'
      : country == MovieCountry.germany
      ? '12'
      : 'PG-13';
}

class FakeActorsRepository extends ActorsRepository {
  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async => [];
}
