import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/season.dart';

class SeasonStyle {
  final String label;
  final Color color;
  final IconData icon;
  final List<double> melody;

  /// Pista de ambiente de la temporada (assets/audio). Si es null se usa la
  /// melodía corta generada en memoria.
  final String? audioAsset;
  const SeasonStyle(
    this.label,
    this.color,
    this.icon,
    this.melody, [
    this.audioAsset,
  ]);
  static SeasonStyle forSeason(Season season) => switch (season) {
    Season.normal => const SeasonStyle(
      'Normal',
      Color(0xFFE91E83),
      Icons.music_note,
      [523, 659, 784],
    ),
    Season.halloween => const SeasonStyle(
      'Halloween',
      Color(0xFFF57C00),
      Icons.nightlight_round,
      [220, 233, 330, 233],
      'audio/halloween.mp3',
    ),
    Season.christmas => const SeasonStyle(
      'Navidad',
      Color(0xFFC62828),
      Icons.ac_unit,
      [659, 659, 659, 659, 784, 523],
      'audio/christmas.mp3',
    ),
    Season.valentines => const SeasonStyle(
      'San Valentín',
      Color(0xFFD32F2F),
      Icons.favorite,
      [523, 659, 784, 659, 523],
      'audio/valentines.mp3',
    ),
  };
}

class AppTheme {
  final Season season;
  AppTheme({this.season = Season.normal});

  ThemeData getTheme() {
    final seasonalText = _seasonalFont(season, const TextStyle());
    final seasonalFamily = seasonalText.fontFamily;
    final primary = SeasonStyle.forSeason(season).color;
    final secondary = switch (season) {
      Season.normal => const Color(0xFFFF4FA0),
      Season.halloween => const Color(0xFFFFA726),
      Season.christmas => const Color(0xFFE57373),
      Season.valentines => const Color(0xFFEF5350),
    };
    final background = switch (season) {
      Season.normal => const Color(0xFFFFF7FB),
      Season.halloween => const Color(0xFFFFE0B2),
      Season.christmas => const Color(0xFFFFCDD2),
      Season.valentines => const Color(0xFFFFCDD2),
    };
    final surfaceContainer = switch (season) {
      Season.normal => const Color(0xFFFFEFF6),
      Season.halloween => const Color(0xFFFFD08A),
      Season.christmas => const Color(0xFFFFCDD2),
      Season.valentines => const Color(0xFFFFBFC2),
    };
    final onSurface = switch (season) {
      Season.normal => const Color(0xFF49384D),
      Season.halloween => const Color(0xFF49311D),
      Season.christmas => const Color(0xFF4A2525),
      Season.valentines => const Color(0xFF4A2828),
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      onPrimary: Colors.white,
      surface: background,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: seasonalFamily,
    );
    final body = base.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );
    final themedText = body.copyWith(
      bodyLarge: _seasonalFont(season, body.bodyLarge),
      bodyMedium: _seasonalFont(season, body.bodyMedium),
      bodySmall: _seasonalFont(season, body.bodySmall),
      labelLarge: _seasonalFont(season, body.labelLarge),
      labelMedium: _seasonalFont(season, body.labelMedium),
      labelSmall: _seasonalFont(season, body.labelSmall),
      displayLarge: _seasonalFont(season, body.displayLarge),
      displayMedium: _seasonalFont(season, body.displayMedium),
      displaySmall: _seasonalFont(season, body.displaySmall),
      headlineLarge: _seasonalFont(season, body.headlineLarge),
      headlineMedium: _seasonalFont(season, body.headlineMedium),
      headlineSmall: _seasonalFont(season, body.headlineSmall),
      titleLarge: _seasonalFont(season, body.titleLarge),
      titleMedium: _seasonalFont(season, body.titleMedium),
      titleSmall: _seasonalFont(season, body.titleSmall),
    );
    return base.copyWith(
      textTheme: themedText,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: _seasonalFont(
          season,
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        unselectedLabelStyle: _seasonalFont(
          season,
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: _seasonalFont(season, const TextStyle()),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: _seasonalFont(
            season,
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: secondary,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

TextStyle _seasonalFont(Season season, TextStyle? style) => switch (season) {
  Season.normal => GoogleFonts.nunito(textStyle: style),
  Season.halloween => GoogleFonts.creepster(textStyle: style),
  Season.christmas => GoogleFonts.mountainsOfChristmas(textStyle: style),
  Season.valentines => GoogleFonts.greatVibes(textStyle: style),
};
