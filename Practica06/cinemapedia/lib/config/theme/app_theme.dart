import 'package:flutter/material.dart';

class AppTheme {
  static const _background = Color(0xFFFFF5F9);
  static const _surface = Color(0xFFFFFFFF);
  static const _pink = Color(0xFFD81B60);
  static const _lightPink = Color(0xFFF48FB1);

  ThemeData getTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _pink,
      brightness: Brightness.light,
      surface: _background,
    ).copyWith(
      primary: _pink,
      onPrimary: Colors.white,
      secondary: _lightPink,
      onSecondary: const Color(0xFF3D1C2E),
      tertiary: const Color(0xFFC2185B),
      surface: _background,
      surfaceContainer: _surface,
      outline: const Color(0xFFE7B9CD),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: const Color(0xFF3D1C2E),
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _pink,
        unselectedItemColor: Color(0xFF9B7E8C),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFF3D8E3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE7B9CD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _pink, width: 1.5),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _pink,
        circularTrackColor: Color(0xFFF8DCE8),
      ),
    );
  }
}
