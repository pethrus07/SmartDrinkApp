import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SDColors {
  // Base
  static const bg = Color(0xFF08081A);
  static const surface = Color(0xFF10102A);
  static const card = Color(0xFF161640);
  static const cardHover = Color(0xFF1E1E50);
  static const border = Color(0xFF252560);

  // Accents
  static const cyan = Color(0xFF00E5FF);
  static const cyanDim = Color(0x4400E5FF);
  static const purple = Color(0xFFA855F7);
  static const purpleDim = Color(0x44A855F7);
  static const orange = Color(0xFFFF6B2B);
  static const pink = Color(0xFFFF2D8A);
  static const green = Color(0xFF00E676);
  static const yellow = Color(0xFFFFD600);

  // Text
  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF9999CC);
  static const textMuted = Color(0xFF555580);

  // Gradients
  static const glowCyan = [Color(0xFF00E5FF), Color(0xFF0088FF)];
  static const glowPurple = [Color(0xFFA855F7), Color(0xFF6B21E8)];
  static const glowMix = [Color(0xFF00E5FF), Color(0xFFA855F7)];

  // Drink ingredient colors
  static const drinkColors = [
    Color(0xFF90CAF9), // Vodka
    Color(0xFFA5D6A7), // Gin
    Color(0xFFFFCC80), // Rum
    Color(0xFF80DEEA), // Energético
    Color(0xFFFFF59D), // Limão
    Color(0xFFCE93D8), // Tônica
  ];
}

class SDTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SDColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: SDColors.cyan,
        secondary: SDColors.purple,
        surface: SDColors.surface,
      ),
      textTheme: GoogleFonts.exo2TextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: SDColors.textPrimary,
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: SDColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: SDColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: SDColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: SDColors.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: SDColors.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SDColors.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SDColors.cyan,
          foregroundColor: SDColors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.exo2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: SDColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SDColors.border, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: SDColors.cyan,
        inactiveTrackColor: SDColors.border,
        thumbColor: SDColors.cyan,
        overlayColor: SDColors.cyanDim,
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      ),
    );
  }
}

// ─── Decorações reutilizáveis ───────────────────────────────
class SDDecorations {
  static BoxDecoration glowCard({Color glowColor = SDColors.cyan}) {
    return BoxDecoration(
      color: SDColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: glowColor.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.15),
          blurRadius: 20,
          spreadRadius: -2,
        ),
      ],
    );
  }

  static BoxDecoration neonBorder({Color color = SDColors.cyan}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.6), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
