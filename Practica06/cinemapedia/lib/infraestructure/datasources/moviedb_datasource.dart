import 'package:cinemapedia/infraestructure/models/moviedb/movie_details.dart';
import 'package:dio/dio.dart';
import 'package:cinemapedia/config/constants/movie_country.dart';

import 'package:cinemapedia/config/constants/enviroment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';

import 'package:cinemapedia/infraestructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infraestructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

class MoviedbDatasource extends MoviesDatasource {
  final MovieCountry country;
  final Dio dio;

  MoviedbDatasource({this.country = MovieCountry.mexico, Dio? client})
    : dio = client ?? Dio() {
    dio.options.baseUrl = 'https://api.themoviedb.org/3';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.queryParameters = {
      'api_key': Environment.theMovieDbKey,
      'language': country.language,
      'region': country.code,
    };
  }

  // Certifications are country-specific; never substitute another country's rating.
  @override
  Future<String?> getCertification(String movieId) async {
    final response = await dio.get('/movie/$movieId/release_dates');
    final results = response.data['results'] as List<dynamic>? ?? [];
    for (final result in results) {
      if (result['iso_3166_1'] != country.code) continue;
      final releases = List<Map<String, dynamic>>.from(
        result['release_dates'] ?? [],
      );
      const preference = [3, 2, 4, 5, 6, 1];
      int priority(dynamic type) {
        final index = preference.indexOf(type);
        return index < 0 ? preference.length : index;
      }

      releases.sort(
        (a, b) => priority(a['type']).compareTo(priority(b['type'])),
      );
      for (final release in releases) {
        final certification = (release['certification'] as String? ?? '')
            .trim();
        if (certification.isNotEmpty) return certification;
      }
    }
    return null;
  }

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
        .where((moviedb) => moviedb.posterPath.isNotEmpty)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response = await dio.get(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await dio.get(
      '/movie/upcoming',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final response = await dio.get('/movie/$id');
    if (response.statusCode != 200) {
      throw Exception('Movie with id: $id not found');
    }

    final movieDetails = MovieDetails.fromJson(response.data);
    final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);
    return movie;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final response = await dio.get(
      '/search/movie',
      queryParameters: {'query': query},
    );

    return _jsonToMovies(response.data);
  }
}
