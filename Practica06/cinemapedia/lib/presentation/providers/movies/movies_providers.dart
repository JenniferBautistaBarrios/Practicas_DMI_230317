import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final nowPlayingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, MovieListState>((ref) {
      return MoviesNotifier(
        fetchMoreMovies: ref.watch(movieRepositoryProvider).getNowPlaying,
      );
    });
final popularMoviesProvider =
    StateNotifierProvider<MoviesNotifier, MovieListState>((ref) {
      return MoviesNotifier(
        fetchMoreMovies: ref.watch(movieRepositoryProvider).getPopular,
      );
    });
final upcomingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, MovieListState>((ref) {
      return MoviesNotifier(
        fetchMoreMovies: ref.watch(movieRepositoryProvider).getUpcoming,
      );
    });
final topRatedMoviesProvider =
    StateNotifierProvider<MoviesNotifier, MovieListState>((ref) {
      return MoviesNotifier(
        fetchMoreMovies: ref.watch(movieRepositoryProvider).getTopRated,
      );
    });

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MovieListState {
  final List<Movie> movies;
  final bool isLoading;
  final bool hasMore;
  final Object? error;
  const MovieListState({
    this.movies = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });
}

class MoviesNotifier extends StateNotifier<MovieListState> {
  int currentPage = 0;
  late final Future<void> initialLoad;
  final MovieCallback fetchMoreMovies;

  MoviesNotifier({required this.fetchMoreMovies})
    : super(const MovieListState()) {
    initialLoad = loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = MovieListState(movies: state.movies, isLoading: true);
    try {
      final movies = await fetchMoreMovies(page: currentPage + 1);
      if (!mounted) return;
      currentPage++;
      final unique = {
        for (final movie in [...state.movies, ...movies]) movie.id: movie,
      };
      state = MovieListState(
        movies: unique.values.toList(),
        hasMore: movies.isNotEmpty,
      );
    } catch (error) {
      if (!mounted) return;
      state = MovieListState(movies: state.movies, error: error);
    }
  }
}
