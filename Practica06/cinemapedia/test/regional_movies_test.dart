import 'dart:async';

import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/infraestructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_slideshow_provider.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  setUp(() => dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test-key'));

  test(
    'All country queries send language and region; certifications stay local',
    () async {
      for (final country in MovieCountry.values) {
        final client = Dio();
        client.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.queryParameters['language'], country.language);
              expect(options.queryParameters['region'], country.code);
              if (options.path.endsWith('/release_dates')) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      'results': [
                        {
                          'iso_3166_1': 'XX',
                          'release_dates': [
                            {'type': 3, 'certification': 'Wrong'},
                          ],
                        },
                        {
                          'iso_3166_1': country.code,
                          'release_dates': [
                            {'type': 4, 'certification': 'Digital'},
                            {'type': 3, 'certification': 'Cinema'},
                          ],
                        },
                      ],
                    },
                  ),
                );
              } else {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      'page': 1,
                      'results': [],
                      'total_pages': 0,
                      'total_results': 0,
                    },
                  ),
                );
              }
            },
          ),
        );
        final source = MoviedbDatasource(country: country, client: client);
        expect(await source.getNowPlaying(), isEmpty);
        expect(await source.getPopular(), isEmpty);
        expect(await source.getUpcoming(), isEmpty);
        expect(await source.getTopRated(), isEmpty);
        expect(await source.getCertification('1'), 'Cinema');
      }
    },
  );

  test(
    'Missing local certification never borrows another country rating',
    () async {
      final client = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'results': [
                      {
                        'iso_3166_1': 'US',
                        'release_dates': [
                          {'type': 3, 'certification': 'R'},
                        ],
                      },
                    ],
                  },
                ),
              );
            },
          ),
        );
      expect(
        await MoviedbDatasource(
          country: MovieCountry.mexico,
          client: client,
        ).getCertification('1'),
        isNull,
      );
    },
  );

  test(
    'Switching country replaces list, detail and certification caches',
    () async {
      final container = ProviderContainer(
        overrides: [
          movieRepositoryProvider.overrideWith(
            (ref) => FakeMoviesRepository(ref.watch(movieCountryProvider)),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        nowPlayingMoviesProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(nowPlayingMoviesProvider.notifier).initialLoad;
      expect(container.read(moviesSlideshowProvider), hasLength(3));
      expect(
        (await container.read(movieInfoProvider('1').future)).title,
        startsWith('MX'),
      );
      expect(await container.read(movieCertificationProvider('1').future), 'B');
      container.read(movieCountryProvider.notifier).state =
          MovieCountry.germany;
      await container.read(nowPlayingMoviesProvider.notifier).initialLoad;
      expect(
        container.read(nowPlayingMoviesProvider).movies.first.title,
        startsWith('DE'),
      );
      expect(
        (await container.read(movieInfoProvider('1').future)).title,
        startsWith('DE'),
      );
      expect(
        await container.read(movieCertificationProvider('1').future),
        '12',
      );
    },
  );

  test(
    'Pagination retries the failed page and stops at an empty result',
    () async {
      final pages = <int>[];
      var fail = true;
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          pages.add(page);
          if (fail) throw Exception('Offline');
          return page == 1 ? [sampleMovie(1)] : <Movie>[];
        },
      );
      addTearDown(notifier.dispose);
      await notifier.initialLoad;
      expect(notifier.state.error, isNotNull);
      expect(notifier.currentPage, 0);
      fail = false;
      await notifier.loadNextPage();
      expect(notifier.state.movies, hasLength(1));
      await notifier.loadNextPage();
      await notifier.loadNextPage();
      expect(pages, [1, 1, 2]);
      expect(notifier.state.hasMore, isFalse);
    },
  );

  test('A disposed regional request cannot overwrite a new list', () async {
    final pending = Completer<List<Movie>>();
    final notifier = MoviesNotifier(
      fetchMoreMovies: ({int page = 1}) => pending.future,
    );
    notifier.dispose();
    pending.complete([sampleMovie(1)]);
    await notifier.initialLoad;
  });
}
