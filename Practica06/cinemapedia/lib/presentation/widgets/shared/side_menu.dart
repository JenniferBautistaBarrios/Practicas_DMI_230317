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
      backgroundColor: colors.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //* Cabecera con el logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CinemapediaLogo(size: 44),
                      const SizedBox(width: 12),
                      Text(
                        'Cinemapedia',
                        style: textStyles.titleLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      'Matrícula: 230317',
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  //* Apartado de configuración
                  Theme(
                    // Quita las líneas que Flutter dibuja arriba y abajo del apartado
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                      childrenPadding: EdgeInsets.zero,
                      iconColor: colors.primary,
                      collapsedIconColor: colors.onSurfaceVariant,
                      leading: Icon(Icons.settings_outlined, color: colors.primary),
                      title: Text(t.settings, style: textStyles.titleMedium),
                      children: [

                        //* Contenido: películas o series
                        _SectionTitle(
                          icon: Icons.video_library_outlined,
                          title: t.content,
                          subtitle: t.chooseContent,
                        ),

                        _CatalogTile(
                          icon: Icons.movie_outlined,
                          label: t.movies,
                          selected: currentCatalog == CatalogType.movies,
                          onTap: () => _changeCatalog(context, ref, CatalogType.movies),
                        ),
                        _CatalogTile(
                          icon: Icons.tv_outlined,
                          label: t.series,
                          selected: currentCatalog == CatalogType.series,
                          onTap: () => _changeCatalog(context, ref, CatalogType.series),
                        ),

                        const SizedBox(height: 12),

                        //* Idioma
                        _SectionTitle(
                          icon: Icons.language_rounded,
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

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 10),
              Text(title, style: textStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textStyles.bodySmall?.copyWith(color: colors.onSurfaceVariant),
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

    return ListTile(
      selected: selected,
      selectedColor: colors.primary,
      selectedTileColor: colors.primary.withValues(alpha: 0.14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, size: 30),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
      onTap: onTap,
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

    return ListTile(
      selected: selected,
      selectedColor: colors.primary,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: FlagIcon(country: language.country, width: 42),
      title: Text(language.label),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
      onTap: onTap,
    );
  }
}
