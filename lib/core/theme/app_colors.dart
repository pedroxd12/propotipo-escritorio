import 'package:flutter/material.dart';

class AppColors {
  // Colores principales basados en el logo
  static const Color primaryColor = Color(0xFF1565C0); // Azul del logo
  static const Color primaryDarkColor = Color(0xFF0D47A1); // Azul oscuro del logo
  static const Color accentColor = Color(0xFF66B3FF); // Azul claro del logo
  static const Color secondaryAccent = Color(0xFF80D0FF); // Celeste del logo

  // Colores neutros modernos
  static const Color backgroundColor = Color(0xFFFAFBFC); // Gris muy claro
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Colores para elementos secundarios
  static const Color surfaceVariant = Color(0xFFF5F7FA); // Para panels y secciones
  static const Color outline = Color(0xFFE1E5E9); // Para bordes sutiles
  static const Color shadow = Color(0x08000000); // Sombras suaves
  static const Color borderColor = Color(0xFFE1E5E9); // Alias para 'outline' usado en temas
  static const Color hoverColor = Color(0xFFF1F5F9); // Color para hover en listas

  // Textos con mejor contraste
  static const Color textPrimaryColor = Color(0xFF1A1D23);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textTertiaryColor = Color(0xFF9CA3AF);
  static const Color textOnPrimaryColor = Colors.white;

  // Estados
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Colores para eventos (más sutiles y modernos)
  static const Color eventBlue = Color(0xFF3B82F6);
  static const Color eventGreen = Color(0xFF059669);
  static const Color eventOrange = Color(0xFFEA580C);
  static const Color eventPurple = Color(0xFF7C3AED);
  static const Color eventPink = Color(0xFFDB2777);
  static const Color eventRed = Color(0xFFDC2626);

  // Header moderno con gradiente sutil
  static const Color headerPrimary = Color(0xFF0D47A1);
  static const Color headerSecondary = Color(0xFF1565C0); // Para gradientes

  // Sidebar y navegación
  static const Color sidebarBackground = Color(0xFFFAFBFC);
  static const Color navItemHover = Color(0xFFF1F5F9);
  static const Color navItemActive = Color(0xFFE0F2FE);
}