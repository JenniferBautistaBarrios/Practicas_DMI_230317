import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_metadata.dart';

class MoviesSlideshow extends ConsumerStatefulWidget {
  final List<Movie> movies;
  const MoviesSlideshow({super.key, required this.movies});

  @override
  ConsumerState<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends ConsumerState<MoviesSlideshow> {
  final controller = PageController(viewportFraction: 0.9);
  double _doubleTapX = 0;
  int _currentPage = 0;
  static const duration = Duration(milliseconds: 300);

  void _goTo(int page) {
    if (!controller.hasClients || widget.movies.isEmpty) return;
    controller.animateToPage(
      page.clamp(0, widget.movies.length - 1),
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;
    final country = ref.watch(movieCountryProvider);
    if (movies.isEmpty) return const SizedBox.shrink();
    final extraHeight = (MediaQuery.textScalerOf(context).scale(90) - 90).clamp(
      0.0,
      180.0,
    );

    return Column(
      children: [
        SizedBox(
          height: 340 + extraHeight,
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                GestureDetector(
                  onDoubleTapDown: (details) =>
                      _doubleTapX = details.localPosition.dx,
                  onDoubleTap: () => _goTo(
                    _currentPage +
                        (_doubleTapX < constraints.maxWidth / 2 ? -1 : 1),
                  ),
                  child: PageView.builder(
                    controller: controller,
                    itemCount: movies.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: InkWell(
                              onTap: () => context.push('/movie/${movie.id}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      movie.backdropPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(
                                        child: Icon(
                                          Icons.movie_outlined,
                                          size: 48,
                                        ),
                                      ),
                                      loadingBuilder: (_, child, progress) =>
                                          progress == null
                                          ? child
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        MovieMetadata(movie: movie),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 70,
                  child: GestureDetector(
                    onDoubleTap: () => _goTo(0),
                    child: IconButton.filledTonal(
                      tooltip:
                          '${country.text('previous')} · 2× ${country.text('start')}',
                      onPressed: () => _goTo(_currentPage - 1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 70,
                  child: GestureDetector(
                    onDoubleTap: () => _goTo(movies.length - 1),
                    child: IconButton.filledTonal(
                      tooltip:
                          '${country.text('next')} · 2× ${country.text('end')}',
                      onPressed: () => _goTo(_currentPage + 1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (index) {
            final active = index == _currentPage;
            return Semantics(
              label: '${index + 1}/${movies.length}',
              selected: active,
              button: true,
              child: GestureDetector(
                onTap: () => _goTo(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: AnimatedContainer(
                    duration: duration,
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
