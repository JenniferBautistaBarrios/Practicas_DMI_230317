import 'package:cinemapedia/domain/entities/movie.dart';

abstract class MoviesDatasource {
  Future<List<Movie>> getNowPlaying({int page = 1});

  Future<List<Movie>> getPopular({int page = 1});

  Future<List<Movie>> getUpcoming({int page = 1});

  Future<List<Movie>> getTopRated({int page = 1});

  Future<String?> getCertification(String movieId);

  Future<Movie> getMovieById(String id);

  Future<List<Movie>> searchMovies(String query);
}
