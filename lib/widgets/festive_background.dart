import 'package:flutter/material.dart';

import '../theme/sd_theme.dart';

/// Fundo festivo: gradiente colorido diagonal com dois "glows" radiais para dar
/// profundidade. Fica atrás de todas as telas do kiosk (montado uma vez em
/// `app.dart`), dando a identidade "vibrante festivo" sem cada tela precisar
/// pintar o próprio fundo.
class FestiveBackground extends StatelessWidget {
  const FestiveBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: SDColors.festiveBg,
        ),
      ),
      child: Stack(
        children: [
          // Glow superior (rosa) e inferior (ciano) — leves halos de cor.
          Positioned(
            top: -120,
            left: -80,
            child: _Glow(color: SDColors.pink.withValues(alpha: 0.45), size: 360),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _Glow(color: SDColors.cyan.withValues(alpha: 0.35), size: 420),
          ),
          Positioned(
            top: 180,
            right: -60,
            child:
                _Glow(color: SDColors.yellow.withValues(alpha: 0.20), size: 260),
          ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
