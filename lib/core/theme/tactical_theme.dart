import 'package:flutter/material.dart';

class TacticalTheme {
  // Paleta Táctica SIMAR GovTech Santa Cruz
  static const Color background = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color surfaceGlass = Color(0xCC111827);
  static const Color surfaceGlassBorder = Color(0x3338BDF8);

  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCrimson = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentSmoke = Color(0xFF94A3B8);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Sombras tácticas con glow
  static List<BoxShadow> glowShadow(Color color, {double blur = 14, double spread = 1}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: blur,
        spreadRadius: spread,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Decoración Glassmorphism estándar
  static BoxDecoration glassDecoration({
    Color? borderColor,
    Color? bgColor,
    double radius = 16.0,
    bool hasGlow = false,
  }) {
    final border = borderColor ?? surfaceGlassBorder;
    return BoxDecoration(
      color: bgColor ?? const Color(0xE6111827),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        if (hasGlow && borderColor != null)
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
      ],
    );
  }

  // ThemeData Dark GovTech
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentCyan,
      canvasColor: background,
      cardColor: surfaceCard,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentEmerald,
        surface: surfaceDark,
        error: accentCrimson,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
