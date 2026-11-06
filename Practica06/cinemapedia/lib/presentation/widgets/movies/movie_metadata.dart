import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MovieMetadata extends ConsumerWidget {
  final Movie movie;
  final bool compact;
  const MovieMetadata({super.key, required this.movie, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    final certification = ref.watch(
      movieCertificationProvider(movie.id.toString()),
    );
    final stars = (movie.voteAverage / 2).clamp(0.0, 5.0);
    final format = NumberFormat('0.0', country.language.replaceAll('-', '_'));
    final label = certification.when(
      data: (value) => value ?? country.text('unrated'),
      loading: () => '…',
      error: (_, _) => country.text('unavailable'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message:
              '${country.text('score')}: ${format.format(movie.voteAverage)}/10 · ${movie.voteCount} ${country.text('votes')}',
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  stars >= index + 1
                      ? Icons.star_rounded
                      : stars >= index + 0.5
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
                  size: compact ? 15 : 20,
                  color: Colors.amber.shade700,
                ),
              ),
              Text(
                '${format.format(stars)}/5',
                style: TextStyle(fontSize: compact ? 11 : 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Tooltip(
          message: certification.hasError
              ? country.text('retry')
              : country.text('rating'),
          child: InkWell(
            onTap: certification.hasError
                ? () => ref.invalidate(
                    movieCertificationProvider(movie.id.toString()),
                  )
                : null,
            child: Text(
              '${country.flag} ${country.code} · $label',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
              semanticsLabel:
                  '${country.text('rating')} ${country.name}: $label',
            ),
          ),
        ),
      ],
    );
  }
}
