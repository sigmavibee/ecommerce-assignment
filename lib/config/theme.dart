import 'package:flutter/material.dart';

// Font settings
class AppFonts {
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Montserrat';
}

// Color palette
class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF004BA0);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFCDFCC6);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

// ThemeData
final ThemeData appTheme = ThemeData(
  fontFamily: AppFonts.primaryFont,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    secondaryContainer: AppColors.accent.withOpacity(0.7),
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontFamily: AppFonts.secondaryFont,
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.secondaryFont,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.primaryFont,
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.primaryFont,
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: AppFonts.secondaryFont,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
