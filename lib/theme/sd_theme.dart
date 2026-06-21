import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual — direção "Vibrante festivo" (v0.4).
///
/// Fundo em gradiente colorido (ver [FestiveBackground]), cards de vidro
/// (branco translúcido com sombra suave), tipografia arredondada (Poppins),
/// cantos generosos e botões em pílula. Sem neon/glow agressivo.
class SDColors {
  // Base / fundo (o gradiente festivo cobre a tela; estes são tons de apoio).
  static const bg = Color(0xFF2A1248); // roxo profundo (texto sobre botão claro)
  static const surface = Color(0xFF2E1552); // diálogos / bottom sheets (sólido)
  static const cardHover = Color(0x33FFFFFF);
  static const border = Color(0x33FFFFFF); // contorno de vidro (branco 20%)

  /// Card de vidro translúcido sobre o gradiente.
  static const card = Color(0x24FFFFFF); // branco ~14%

  // Acentos vivos (festivos)
  static const cyan = Color(0xFF22D3EE);
  static const cyanDim = Color(0x4422D3EE);
  static const purple = Color(0xFFC084FC);
  static const purpleDim = Color(0x44C084FC);
  static const orange = Color(0xFFFF8A3D);
  static const pink = Color(0xFFFF4D9D);
  static const green = Color(0xFF34E3A0);
  static const yellow = Color(0xFFFFD84D);

  // Texto (claro — sobre vidro/gradiente)
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFE7DCFF);
  static const textMuted = Color(0xFFB9A6E0);

  // Gradientes de acento (botões/realces)
  static const glowCyan = [Color(0xFF22D3EE), Color(0xFF3B82F6)];
  static const glowPurple = [Color(0xFFC084FC), Color(0xFF8B5CF6)];
  static const glowMix = [Color(0xFFFF4D9D), Color(0xFFFF8A3D)];

  /// Gradiente festivo de fundo (usado por [FestiveBackground]).
  static const festiveBg = [
    Color(0xFF6D28D9), // roxo
    Color(0xFFDB2777), // magenta
    Color(0xFFF97316), // laranja
  ];

  // Cores dos ingredientes (mantidas — identificam cada reservatório)
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
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // o gradiente festivo cobre
      colorScheme: const ColorScheme.dark(
        primary: SDColors.cyan,
        secondary: SDColors.purple,
        surface: SDColors.surface,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: SDColors.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SDColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: SDColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SDColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: SDColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: SDColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: SDColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SDColors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // pílula
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SDColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: SDColors.border, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: SDColors.pink,
        inactiveTrackColor: SDColors.border,
        thumbColor: Colors.white,
        overlayColor: SDColors.pink.withValues(alpha: 0.2),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      ),
    );
  }
}

// ─── Decorações reutilizáveis (cards de vidro festivos) ─────────────
class SDDecorations {
  /// Card de vidro: branco translúcido, contorno sutil e sombra suave —
  /// "flutua" sobre o gradiente. Mantém a assinatura antiga ([glowColor] é
  /// usado só como leve tom de realce) para o restyle propagar às telas.
  static BoxDecoration glowCard({Color glowColor = SDColors.purple}) {
    return BoxDecoration(
      color: SDColors.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 24,
          spreadRadius: -6,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Estado selecionado/destacado: contorno mais forte na cor de acento.
  static BoxDecoration neonBorder({Color color = SDColors.cyan}) {
    return BoxDecoration(
      color: SDColors.cardHover,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: color.withValues(alpha: 0.9), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 18,
          spreadRadius: -4,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
