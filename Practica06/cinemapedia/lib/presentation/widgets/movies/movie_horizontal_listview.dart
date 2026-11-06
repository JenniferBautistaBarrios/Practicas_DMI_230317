import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MovieHorizontalListview extends ConsumerStatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;
  final bool isLoading;
  final Object? error;

  const MovieHorizontalListview({
    super.key,
    required this.movies,
    this.title,
    this.subTitle,
    this.loadNextPage,
    this.isLoading = false,
    this.error,
  });

  @override
  ConsumerState<MovieHorizontalListview> createState() =>
      _MovieHorizontalListviewState();
}

class _MovieHorizontalListviewState
    extends ConsumerState<MovieHorizontalListview> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (widget.isLoading || widget.error != null) return;
      if (scrollController.position.extentAfter < 200) {
        widget.loadNextPage?.call();
      }
    });
  }

  void _move(bool forward, {bool edge = false}) {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final target = edge
        ? (forward ? position.maxScrollExtent : 0.0)
        : (position.pixels + (forward ? 1 : -1) * 300).clamp(
            0.0,
            position.maxScrollExtent,
          );
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (widget.movies.isNotEmpty) ...[
                  GestureDetector(
                    onDoubleTap: () => _move(false, edge: true),
                    child: IconButton(
                      tooltip:
                          '${country.text('previous')} · 2× ${country.text('start')}',
                      onPressed: () => _move(false),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () => _move(true, edge: true),
                    child: IconButton(
                      tooltip:
                          '${country.text('next')} · 2× ${country.text('end')}',
                      onPressed: () => _move(true),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(country.text('error')),
                  TextButton.icon(
                    onPressed: widget.loadNextPage,
                    icon: const Icon(Icons.refresh),
                    label: Text(country.text('retry')),
                  ),
                ],
              ),
            ),
          if (widget.movies.isEmpty && widget.error == null)
            SizedBox(
              height: 100,
              child: Center(
                child: widget.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(country.text('empty')),
              ),
            ),
          if (widget.movies.isNotEmpty)
            SizedBox(
              height:
                  310 +
                  (MediaQuery.textScalerOf(context).scale(150) - 150).clamp(
                    0,
                    150,
                  ),
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: widget.movies.length + (widget.isLoading ? 1 : 0),
                itemBuilder: (context, index) => index == widget.movies.length
                    ? const SizedBox(
                        width: 64,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _Slide(movie: widget.movies[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;
  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/movie/${movie.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.posterPath,
                  width: 144,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 144,
                    height: 200,
                    child: Icon(Icons.movie_outlined, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              MovieMetadata(movie: movie, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
