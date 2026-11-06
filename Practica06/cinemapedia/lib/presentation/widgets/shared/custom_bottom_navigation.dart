import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavigation extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: country.text('home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.local_movies_outlined),
          label: country.text('nowPlaying'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.trending_up_rounded),
          label: country.text('popular'),
        ),
      ],
    );
  }
}
