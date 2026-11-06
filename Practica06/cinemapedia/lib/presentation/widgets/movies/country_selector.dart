import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountrySelector extends ConsumerWidget {
  const CountrySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(movieCountryProvider);
    return PopupMenuButton<MovieCountry>(
      tooltip: selected.text('country'),
      initialValue: selected,
      onSelected: (country) =>
          ref.read(movieCountryProvider.notifier).state = country,
      itemBuilder: (_) => MovieCountry.values
          .map(
            (country) => PopupMenuItem(
              value: country,
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(country.name),
                        Text(
                          '${country.continent} · ${country.language}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (country == selected) const Icon(Icons.check, size: 18),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 25)),
            const SizedBox(width: 4),
            Text(selected.code),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}
