import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/country_selector.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:cinemapedia/domain/entities/movie.dart';

import 'package:cinemapedia/presentation/providers/actors/actors_by_movie_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    final result = ref.watch(movieInfoProvider(widget.movieId));
    final movie = result.asData?.value;
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(actions: const [CountrySelector()]),
        body: Center(
          child: result.isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.text('error'), textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(movieInfoProvider(widget.movieId)),
                        child: Text(country.text('retry')),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MovieDetails(movie: movie),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                  errorBuilder: (_, _, _) => SizedBox(
                    width: size.width * 0.3,
                    height: 160,
                    child: const Icon(Icons.movie_outlined),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Descripción
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textStyles.titleLarge),
                    const SizedBox(height: 8),
                    MovieMetadata(movie: movie),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview.isEmpty
                          ? country.text('overview')
                          : movie.overview,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Generos de la película
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map(
                (gender) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Chip(
                    label: Text(gender),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(country.text('cast'), style: textStyles.titleLarge),
        ),
        _ActorsByMovie(movieId: movie.id.toString()),

        const SizedBox(height: 50),
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;

  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final country = ref.watch(movieCountryProvider);
    final result = ref.watch(actorsByMovieProvider(movieId));
    if (result.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (result.hasError) {
      return TextButton(
        onPressed: () => ref.invalidate(actorsByMovieProvider(movieId)),
        child: Text(country.text('retry')),
      );
    }
    final actors = result.asData?.value ?? [];

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Actor Photo
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        height: 180,
                        width: 135,
                        child: Icon(Icons.person_outline, size: 48),
                      ),
                    ),
                  ),
                ),

                // Nombre
                const SizedBox(height: 5),

                Text(actor.name, maxLines: 2),
                Text(
                  actor.character ?? '',
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      actions: const [CountrySelector()],
      pinned: true,
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.movie_outlined,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.7, 1.0],
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),

            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    stops: [0.0, 0.3],
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
