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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFFF3D8E3)),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: t.home,
                selected: currentIndex == 0,
                onTap: () => onItemTapped(context, 0),
              ),
              _NavItem(
                icon: Icons.local_fire_department_outlined,
                selectedIcon: Icons.local_fire_department_rounded,
                label: t.popular,
                selected: currentIndex == 1,
                onTap: () => onItemTapped(context, 1),
              ),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: t.favorites,
                selected: currentIndex == 2,
                onTap: () => onItemTapped(context, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NavItem extends StatelessWidget {

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final inactive = colors.onSurfaceVariant;

    return Expanded(
      // La opción seleccionada ocupa más espacio para mostrar su texto
      flex: selected ? 5 : 3,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [colors.primary, colors.tertiary])
                : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected ? colors.onPrimary : inactive,
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
