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

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      elevation: 0,
      selectedItemColor: colors.primary,
      items: [
        BottomNavigationBarItem(
          icon: const Icon( Icons.home_max ),
          label: t.home
        ),
        BottomNavigationBarItem(
          icon: const Icon( Icons.thumbs_up_down_outlined ),
          label: t.popular
        ),
        BottomNavigationBarItem(
          icon: const Icon( Icons.favorite_outline ),
          label: t.favorites
        ),
      ]
    );
  }
}