import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';
import 'package:cinemapedia/presentation/widgets/shared/flag_icon.dart';

/// Menú lateral (drawer). Se abre con el botón de la barra o deslizando
/// desde el borde de la pantalla, y se cierra deslizando hacia el borde.
///
/// Tiene un apartado de **Configuración** con:
///  - Contenido: Películas o Series.
///  - Idioma: español, inglés, alemán, chino y árabe (se recuerda al cerrar la app).
class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final t = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final currentLanguage = ref.watch(languageProvider);
    final currentCatalog = ref.watch(catalogTypeProvider);

    return Drawer(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(28),
          bottomEnd: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //* Cabecera con degradado y el logo
          _Header(colors: colors, textStyles: textStyles),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [

                //* Apartado de configuración (tarjeta desplegable)
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
                  ),
                  child: Theme(
                    // Quita las líneas que Flutter dibuja arriba y abajo del apartado
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      iconColor: colors.primary,
                      collapsedIconColor: colors.onSurfaceVariant,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.settings_rounded, color: colors.primary, size: 22),
                      ),
                      title: Text(
                        t.settings,
                        style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      children: [

                        //* Contenido: películas o series
                        _SectionTitle(
                          icon: Icons.video_library_rounded,
                          title: t.content,
                          subtitle: t.chooseContent,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _CatalogTile(
                                icon: Icons.movie_creation_outlined,
                                label: t.movies,
                                selected: currentCatalog == CatalogType.movies,
                                onTap: () => _changeCatalog(context, ref, CatalogType.movies),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CatalogTile(
                                icon: Icons.live_tv_rounded,
                                label: t.series,
                                selected: currentCatalog == CatalogType.series,
                                onTap: () => _changeCatalog(context, ref, CatalogType.series),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        //* Idioma
                        _SectionTitle(
                          icon: Icons.translate_rounded,
                          title: t.language,
                          subtitle: t.chooseLanguage,
                        ),

                        for (final language in AppLanguages.all)
                          _LanguageTile(
                            language: language,
                            selected: language == currentLanguage,
                            onTap: () {
                              changeLanguage(ref, language); // también lo guarda
                              Navigator.of(context).pop();   // cierra el menú
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeCatalog(BuildContext context, WidgetRef ref, CatalogType type) {
    ref.read(catalogTypeProvider.notifier).state = type;

    // El texto de la última búsqueda era del otro catálogo
    ref.read(searchQueryProvider.notifier).state = '';

    Navigator.of(context).pop(); // cierra el menú
  }
}


class _Header extends StatelessWidget {

  final ColorScheme colors;
  final TextTheme textStyles;

  const _Header({required this.colors, required this.textStyles});

  @override
  Widget build(BuildContext context) {

    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 24, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary, colors.secondary],
        ),
        borderRadius: const BorderRadiusDirectional.only(
          topEnd: Radius.circular(28),
          bottomEnd: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CinemapediaLogo(size: 46),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cinemapedia',
                  style: textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Matrícula: 230317',
                    style: textStyles.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textStyles.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textStyles.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _CatalogTile extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatalogTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.onPrimary : colors.onSurface;

    return Material(
      color: selected ? colors.primary : colors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? colors.primary : colors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: foreground),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, size: 16, color: foreground),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _LanguageTile extends StatelessWidget {

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? colors.primary : colors.outline.withValues(alpha: 0.45),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                FlagIcon(country: language.country, width: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language.label,
                    style: TextStyle(
                      color: selected ? colors.primary : colors.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? colors.primary : colors.outline,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 15, color: colors.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
