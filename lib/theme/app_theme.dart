import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      fontFamily: 'Roboto', // Puedes cambiar la fuente aquí

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        iconTheme: IconThemeData(color: AppColors.textPrimaryColor),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondaryColor),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimaryColor),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimaryColor),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryColor),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryColor),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textOnPrimaryColor),
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
        primary: AppColors.primaryColor,
        onPrimary: AppColors.textOnPrimaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.surfaceColor,
        background: AppColors.backgroundColor,
        error: AppColors.errorColor,
      ).copyWith(surfaceContainerHighest: AppColors.surfaceColor), // Para el fondo de diálogos, etc. en M3

      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, color: AppColors.textOnPrimaryColor),
        decoration: BoxDecoration(
          color: AppColors.textPrimaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
      ),

    /* cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surfaceColor,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      */
    );
  }
}