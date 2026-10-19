import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../config/theme/season_icons.dart';
import '../../../domain/entities/season.dart';
import '../../providers/preferences_provider.dart';

/// Compact seasonal selector with small circular artwork and soft pastel cards.
class SeasonSettings extends StatelessWidget {
  const SeasonSettings({super.key});

  Future<void> _save(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la preferencia.')),
        );
      }
    }
  }

  Future<void> _selectSeason(
    BuildContext context,
    Future<void> Function() save,
  ) async {
    await _save(context, save);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final selected = prefs.repository.seasonOverride?.name ?? 'auto';
    final theme = Theme.of(context);
    final active = SeasonStyle.forSeason(prefs.season);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.surfaceContainer, Theme.of(context).colorScheme.surfaceContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .45), width: .9),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Temporada visual',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Elige la vibra que más te guste',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                      _ActiveChip(label: active.label, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Automático: octubre, diciembre y 1–14 de febrero. '
                  'La prueba se guarda en el dispositivo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF917E91),
                  ),
                ),
                const SizedBox(height: 8),
                _AutoCard(
                  selected: selected == 'auto',
                  color: Theme.of(context).colorScheme.primary,
                  todayLabel: active.label,
                  onTap: () => _selectSeason(
                    context,
                    () => prefs.setSeason(null),
                  ),
                ),
                const SizedBox(height: 8),
                for (final row in const [
                  [Season.normal, Season.halloween],
                  [Season.christmas, Season.valentines],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        for (var i = 0; i < row.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _SeasonCard(
                              season: row[i],
                              selected: selected == row[i].name,
                              onTap: () => _selectSeason(
                                context,
                                () => prefs.setSeason(row[i]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                _AudioCard(
                  value: prefs.repository.seasonalAudio,
                  color: Theme.of(context).colorScheme.primary,
                  onChanged: () => _save(context, prefs.toggleAudio),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ActiveChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .45), width: .8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 5),
        Text(
          'Ahora: $label',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

class _AutoCard extends StatelessWidget {
  final bool selected;
  final Color color;
  final String todayLabel;
  final VoidCallback onTap;

  const _AutoCard({
    required this.selected,
    required this.color,
    required this.todayLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: selected ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withValues(alpha: .45),
        width: selected ? 1.2 : .8,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Icon(Icons.auto_awesome, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Automático',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Hoy toca: $todayLabel',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF927F91),
                      ),
                    ),
                  ],
                ),
              ),
              _CheckDot(selected: selected, color: color),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SeasonCard extends StatelessWidget {
  final Season season;
  final bool selected;
  final VoidCallback onTap;

  const _SeasonCard({
    required this.season,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = SeasonStyle.forSeason(season);
    return Semantics(
      button: true,
      selected: selected,
      label: style.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 78,
        decoration: BoxDecoration(
          color: selected
              ? style.color.withValues(alpha: .16)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: style.color.withValues(alpha: selected ? 1 : .45),
            width: selected ? 1.2 : .8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  Container(
                  width: 54,
                  height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    padding: const EdgeInsets.all(1),
                    child: ClipOval(
                      child: Image.asset(
                        SeasonIcons.assetFor(season),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      style.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      color: style.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  _CheckDot(selected: selected, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  final bool selected;
  final Color color;
  const _CheckDot({required this.selected, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 160),
    child: Icon(
      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
      key: ValueKey(selected),
      color: selected ? color : const Color(0xFFD8BFCB),
      size: 18,
    ),
  );
}

class _AudioCard extends StatelessWidget {
  final bool value;
  final Color color;
  final VoidCallback onChanged;

  const _AudioCard({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .45), width: .8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: SwitchListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
      secondary: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surfaceContainer),
        child: Icon(
          value ? Icons.music_note : Icons.music_off,
          color: color,
          size: 18,
        ),
      ),
      value: value,
      title: Text(
        'Melodía al cambiar temporada',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Respeta el botón de silenciar videos.',
        style: TextStyle(fontSize: 11, color: Color(0xFF927F91)),
      ),
      activeThumbColor: Theme.of(context).colorScheme.primary,
      activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: .35),
      inactiveThumbColor: const Color(0xFFD8BFCB),
      inactiveTrackColor: const Color(0xFFF5E7EE),
      onChanged: (_) => onChanged(),
    ),
  );
}
