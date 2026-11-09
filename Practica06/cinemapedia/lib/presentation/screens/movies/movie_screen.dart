import 'package:cinemapedia/config/helpers/age_rating.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:cinemapedia/domain/entities/movie.dart';

import 'package:cinemapedia/presentation/providers/providers.dart';


class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();
    
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if ( movie == null ) {
      return const Scaffold(body: Center( child: CircularProgressIndicator( strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))
        ],
      ),
    );
  }
}


class _MovieDetails extends StatelessWidget {
  
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //* Titulo, OverView y Rating
        _TitleAndOverview(movie: movie, size: size, textStyles: textStyles),

        //* Generos de la película
        _Genres(movie: movie),


        //* Actores de la película
        ActorsByMovie(movieId: movie.id.toString() ),

        //* Videos de la película (si tiene)
        VideosFromMovie( movieId: movie.id ),

        //* Películas similares
        SimilarMovies(movieId: movie.id ),

      ],
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            ...movie.genreIds.map((gender) => Container(
              margin: const EdgeInsets.only( right: 10),
              child: Chip(
                label: Text( gender ),
                shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class _TitleAndOverview extends ConsumerWidget {
  const _TitleAndOverview({
    required this.movie,
    required this.size,
    required this.textStyles,
  });

  final Movie movie;
  final Size size;
  final TextTheme textStyles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final t = AppStrings.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final colors = Theme.of(context).colorScheme;

    // Clasificación de edad según el país del idioma elegido (MX, US, DE...)
    final country = ref.watch( languageProvider ).country;
    final certification = ref.watch( movieCertificationProvider(movie.id) );

    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 8, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              movie.posterPath,
              width: size.width * 0.3,
            ),
          ),

          const SizedBox( width: 10 ),

          // Descripción
          SizedBox(
            width: (size.width - 40) * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( movie.title, style: textStyles.titleLarge ),
                Text( movie.overview ),

                const SizedBox(height: 10 ),
                
                MovieRating(voteAverage: movie.voteAverage ),

                Row(
                  children: [
                    Text(t.releaseDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5 ),
                    Flexible(child: Text(HumanFormats.shortDate(movie.releaseDate, languageCode)))
                  ],
                ),

                const SizedBox(height: 6 ),

                //* Clasificación de edad del país elegido
                certification.when(
                  loading: () => const SizedBox(height: 24),
                  error: (_, __) => _AgeRatingBadge(label: t.ageRating, rating: AgeRatings.label(country, ''), country: country, color: colors.primary),
                  data: (value) => _AgeRatingBadge(label: t.ageRating, rating: AgeRatings.label(country, value), country: country, color: colors.primary),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}


class _AgeRatingBadge extends StatelessWidget {

  final String label;
  final String rating;
  final String country;
  final Color color;

  const _AgeRatingBadge({
    required this.label,
    required this.rating,
    required this.country,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric( horizontal: 8, vertical: 2 ),
          decoration: BoxDecoration(
            border: Border.all( color: color ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            rating,
            style: TextStyle( color: color, fontWeight: FontWeight.bold ),
          ),
        ),
        Text('($country)', style: TextStyle( color: Theme.of(context).colorScheme.onSurfaceVariant )),
      ],
    );
  }
}


final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId);
});



class _CustomSliverAppBar extends ConsumerWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
          IconButton(onPressed: () async {
            
            // ref.read(localStorageRepositoryProvider)
            //   .toggleFavorite(movie);
            await ref.read( favoriteMoviesProvider.notifier )
              .toggleFavorite(movie);
            
            ref.invalidate(isFavoriteProvider(movie.id));


          }, 
          icon: isFavoriteFuture.when(
            loading: () => const CircularProgressIndicator(strokeWidth: 2 ),
            data: (isFavorite) => isFavorite 
              ? Icon( Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary )
              : const Icon( Icons.favorite_border ), 
            error: (_, __) => throw UnimplementedError(), 
          ),
          
          // const Icon( Icons.favorite_border )
          // icon: const Icon( Icons.favorite_rounded, color: Colors.red )
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 0),
        title:  _CustomGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.7, 1.0],
          colors: [
            Colors.transparent,
            scaffoldBackgroundColor
          ]
        ),
        background: Stack(
          children: [

            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            //* Favorite Gradient Background
            const _CustomGradient(
               begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.0, 0.2],
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ]
            ),


            //* Back arrow background
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3],
              colors: [
                Colors.black87,
                Colors.transparent,
              ]
            ),
                

          ],
        ),
      ),
    );
  }
}



class _CustomGradient extends StatelessWidget {

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient({
    this.begin = Alignment.centerLeft, 
    this.end = Alignment.centerRight, 
    required this.stops, 
    required this.colors
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors
          )
        )
      ),
    );
  }
}


