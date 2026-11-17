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
      final loadError = ref.read(movieInfoProvider.notifier).loadErrorFor(widget.movieId);
      return Scaffold(
        body: Center(
          child: loadError == null
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 40),
                    const SizedBox(height: 12),
                    const Text('No se pudo cargar la película.'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
        ),
      );
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
        FadeInUp(
          duration: const Duration(milliseconds: 450),
          child: _TitleAndOverview(movie: movie, size: size, textStyles: textStyles),
        ),

        //* Generos de la película
        _Genres(movie: movie),

        const SizedBox(height: 10),

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

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...movie.genreIds.map((gender) => Chip(
              label: Text(
                gender,
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
              ),
              backgroundColor: colors.primary.withValues(alpha: 0.10),
              side: BorderSide(color: colors.primary.withValues(alpha: 0.25)),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Imagen
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LoadingNetworkImage(
                    url: movie.posterPath,
                    width: size.width * 0.34,
                  ),
                ),
              ),

              const SizedBox( width: 16 ),

              // Título, rating, fecha y clasificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 12 ),

                    //* Rating
                    _InfoPill(
                      color: Colors.amber.shade800,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade800),
                          const SizedBox(width: 4),
                          Text(
                            HumanFormats.number(movie.voteAverage, 1),
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8 ),

                    //* Fecha de estreno
                    _InfoPill(
                      color: colors.primary,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16, color: colors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${t.releaseDate} ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: HumanFormats.shortDate(movie.releaseDate, languageCode)),
                                ],
                              ),
                              style: TextStyle(color: colors.onSurface, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10 ),

                    //* Clasificación de edad del país elegido
                    certification.when(
                      loading: () => const SizedBox(height: 24),
                      error: (_, __) => _AgeRatingBadge(label: t.ageRating, rating: AgeRatings.label(country, ''), country: country, color: colors.primary),
                      data: (value) => _AgeRatingBadge(label: t.ageRating, rating: AgeRatings.label(country, value), country: country, color: colors.primary),
                    ),
                  ],
                ),
              ),

            ],
          ),

          //* Descripción en tarjeta
          if ( movie.overview.isNotEmpty ) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF3D8E3)),
              ),
              child: Text(
                movie.overview,
                style: textStyles.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],

        ],
      ),
    );
  }
}


/// Cápsula con fondo suave para datos cortos (rating, fecha).
class _InfoPill extends StatelessWidget {

  final Color color;
  final Widget child;

  const _InfoPill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
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
      runSpacing: 4,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric( horizontal: 10, vertical: 3 ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            rating,
            style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold ),
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


/// Botón circular blanco que flota sobre la imagen del encabezado.
class _CircleButton extends StatelessWidget {

  final Widget child;

  const _CircleButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        elevation: 2,
        shadowColor: Colors.black38,
        shape: const CircleBorder(),
        child: SizedBox.square(
          dimension: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {

  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _CircleButton(
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: Icon(icon, size: 22, color: color ?? const Color(0xFF3D1C2E)),
      ),
    );
  }
}


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
    final primary = Theme.of(context).colorScheme.primary;

    return SliverAppBar(
      pinned: true,
      backgroundColor: scaffoldBackgroundColor,
      expandedHeight: size.height * 0.5,
      foregroundColor: Colors.white,
      leadingWidth: 56,
      leading: Navigator.of(context).canPop()
          ? _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      actions: [
        isFavoriteFuture.when(
          loading: () => const _CircleButton(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          data: (isFavorite) => _CircleIconButton(
            onPressed: () async {
              try {
                await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(
                  movie,
                  isCurrentlyFavorite: isFavorite,
                );
                ref.invalidate(isFavoriteProvider(movie.id));
              } catch (error, stackTrace) {
                debugPrint('Error al guardar favorito: $error\n$stackTrace');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo guardar el favorito: $error'),
                  ),
                );
              }
            },
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? primary : null,
          ),
          error: (_, __) => _CircleIconButton(
            onPressed: () => ref.invalidate(isFavoriteProvider(movie.id)),
            icon: Icons.favorite_border_rounded,
          ),
        ),
        const SizedBox(width: 4),
      ],

      //* Borde superior redondeado que "sube" sobre la imagen
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: Container(
          height: 24,
          decoration: BoxDecoration(
            color: scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [

            SizedBox.expand(
              child: LoadingNetworkImage(
                // El encabezado ocupa casi toda la pantalla: usa el arte
                // horizontal para que no se recorte el póster vertical.
                url: movie.backdropPath,
                fit: BoxFit.cover,
              ),
            ),

            //* Sombra superior para que se vean los botones
            const _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.25],
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),

            //* Sombra suave abajo para fundir con el fondo
            _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.75, 1.0],
              colors: [
                Colors.transparent,
                scaffoldBackgroundColor.withValues(alpha: 0.6),
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
