// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      fontFamily: GoogleFonts.lato().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.textOnPrimaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.backgroundColor, // CORREGIDO: 'background' a 'surface'
        error: AppColors.errorColor,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.lato(
          color: AppColors.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        labelStyle: GoogleFonts.lato(color: AppColors.textSecondaryColor),
        hintStyle: GoogleFonts.lato(color: AppColors.textTertiaryColor),
      ),

      textTheme: GoogleFonts.latoTextTheme().copyWith(
        headlineSmall: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkColor),
        titleLarge: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
        titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryColor),
        bodyLarge: GoogleFonts.lato(fontSize: 15, color: AppColors.textPrimaryColor),
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: AppColors.textSecondaryColor, height: 1.5),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primaryDarkColor,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}