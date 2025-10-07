import 'package:flutter/material.dart';

/// EDU BLUE – PALETTE
class EduColors {
  // Core
  static const primary = Color(0xFF3B82F6); // Sky Blue
  static const primaryDark = Color(0xFF1D4ED8); // Deep Blue
  static const primaryLight = Color(0xFF93C5FD); // Baby Blue

  // Neutrals
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF3F4F6);

  // Text
  static const textPrimary = Color(0xFF1E293B); // Dark Navy
  static const textSecondary = Color(0xFF64748B); // Slate Gray

  // Status
  static const info = Color(0xFF0EA5E9); // Mint Blue
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

/// LIGHT THEME
final ThemeData eduLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: EduColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: EduColors.primary,
        onPrimary: Colors.white,
        primaryContainer: EduColors.primaryLight,
        onPrimaryContainer: EduColors.textPrimary,
        surface: EduColors.surface,
        onSurface: EduColors.textPrimary,
        background: EduColors.background,
        onBackground: EduColors.textPrimary,
        secondary: EduColors.primaryDark,
        onSecondary: Colors.white,
        error: EduColors.error,
        onError: Colors.white,
      ),
  scaffoldBackgroundColor: EduColors.background,

  // Typography
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      color: EduColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: EduColors.textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: EduColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: EduColors.textSecondary),
    labelLarge: TextStyle(fontWeight: FontWeight.w600),
  ),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: EduColors.primaryDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),

  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: EduColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: EduColors.primary),
      foregroundColor: EduColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: EduColors.primaryDark),
  ),

  // Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: EduColors.primaryLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: EduColors.primaryLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: EduColors.primary, width: 2),
    ),
  ),

  // Cards

  // Chips / Badges
  chipTheme: const ChipThemeData(
    backgroundColor: EduColors.surface,
    selectedColor: EduColors.primaryLight,
    labelStyle: TextStyle(color: EduColors.textSecondary),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    side: BorderSide(color: EduColors.primaryLight),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    shape: StadiumBorder(),
  ),

  // SnackBar / Dialog
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: EduColors.primaryDark,
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
  ),
);

/// DARK THEME
final ThemeData eduDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: EduColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: EduColors.primaryLight,
        onPrimary: Colors.black,
        primaryContainer: EduColors.primaryDark,
        onPrimaryContainer: Colors.white,
        surface: const Color(0xFF0F172A), // dark slate
        onSurface: Colors.white,
        background: const Color(0xFF0B1222),
        onBackground: Colors.white,
        secondary: EduColors.info,
        error: EduColors.error,
      ),
  scaffoldBackgroundColor: const Color(0xFF0B1222),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F172A),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: EduColors.primaryLight,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0F172A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1E293B)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: EduColors.primaryLight, width: 2),
    ),
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFF1F2937),
    selectedColor: EduColors.primaryDark,
    labelStyle: TextStyle(color: Color(0xFFE5E7EB)),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    side: BorderSide(color: Color(0xFF334155)),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    shape: StadiumBorder(),
  ),
);
