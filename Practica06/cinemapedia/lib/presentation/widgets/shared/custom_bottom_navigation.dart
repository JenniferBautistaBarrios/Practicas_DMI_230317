import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/i18n/app_strings.dart';


class CustomBottomNavigation extends StatelessWidget {

  final int currentIndex;

  const CustomBottomNavigation({
    super.key, 
    required this.currentIndex
  });

  void onItemTapped( BuildContext context, int index ) {
    // context.go('');
    switch(index) {
      case 0:
        context.go('/home/0');
        break;
      
      case 1:
        context.go('/home/1');
        break;

      case 2:
        context.go('/home/2');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final t = AppStrings.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (value) => onItemTapped(context, value),
            height: 68,
            elevation: 0,
            backgroundColor: colors.surfaceContainer,
            indicatorColor: colors.primary.withValues(alpha: 0.16),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: t.home),
              NavigationDestination(icon: const Icon(Icons.local_fire_department_outlined), selectedIcon: const Icon(Icons.local_fire_department_rounded), label: t.popular),
              NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: t.favorites),
            ],
          ),
        ),
      ),
    );
  }
}
