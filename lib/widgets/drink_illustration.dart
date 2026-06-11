import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/drink_models.dart';

/// Widget que gera uma ilustração de copo de drink colorido
/// baseado nos ingredientes — substitui os emojis por visual real.
class DrinkIllustration extends StatelessWidget {
  final List<DrinkPortion> portions;
  final double size;

  const DrinkIllustration({
    super.key,
    required this.portions,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DrinkGlassPainter(portions: portions),
      ),
    );
  }
}

class _DrinkGlassPainter extends CustomPainter {
  final List<DrinkPortion> portions;

  _DrinkGlassPainter({required this.portions});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dimensões do copo
    final glassTop = h * 0.08;
    final glassBottom = h * 0.88;
    final glassHeight = glassBottom - glassTop;
    final topWidth = w * 0.75;
    final bottomWidth = w * 0.45;
    final topLeft = (w - topWidth) / 2;
    final bottomLeft = (w - bottomWidth) / 2;

    // Path do copo (trapézio)
    final glassPath = Path()
      ..moveTo(topLeft, glassTop)
      ..lineTo(bottomLeft, glassBottom)
      ..lineTo(bottomLeft + bottomWidth, glassBottom)
      ..lineTo(topLeft + topWidth, glassTop)
      ..close();

    // ── Preencher com camadas de ingredientes ──
    canvas.save();
    canvas.clipPath(glassPath);

    final totalMl = portions.fold(0, (s, p) => s + p.ml);
    if (totalMl > 0) {
      // Preencher ~85% do copo
      final fillHeight = glassHeight * 0.85;
      var currentBottom = glassBottom;

      for (final portion in portions) {
        if (portion.ml <= 0) continue;
        final layerRatio = portion.ml / totalMl;
        final layerHeight = fillHeight * layerRatio;
        final layerTop = currentBottom - layerHeight;

        final ing = defaultIngredients.firstWhere(
          (i) => i.reservoir == portion.reservoir,
          orElse: () => defaultIngredients[0],
        );

        // Gradiente vertical na camada
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ing.color.withOpacity(0.9),
              ing.color.withOpacity(0.6),
            ],
          ).createShader(Rect.fromLTRB(0, layerTop, w, currentBottom));

        canvas.drawRect(
          Rect.fromLTRB(0, layerTop, w, currentBottom),
          paint,
        );

        // Linha divisória sutil entre camadas
        if (currentBottom < glassBottom) {
          final dividerPaint = Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..strokeWidth = 1;
          canvas.drawLine(
            Offset(0, currentBottom),
            Offset(w, currentBottom),
            dividerPaint,
          );
        }

        currentBottom = layerTop;
      }

      // Brilho no topo do líquido
      final surfaceY = glassBottom - fillHeight;
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(0, surfaceY, w, surfaceY + 8));
      canvas.drawRect(
        Rect.fromLTRB(0, surfaceY, w, surfaceY + 8),
        highlightPaint,
      );
    }

    canvas.restore();

    // ── Outline do copo ──
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(glassPath, outlinePaint);

    // ── Reflexo lateral (vidro) ──
    final reflectPath = Path()
      ..moveTo(topLeft + 4, glassTop + 4)
      ..lineTo(bottomLeft + 3, glassBottom - 4)
      ..lineTo(bottomLeft + 6, glassBottom - 4)
      ..lineTo(topLeft + 7, glassTop + 4)
      ..close();
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.15);
    canvas.drawPath(reflectPath, reflectPaint);

    // ── Base do copo ──
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(bottomLeft - 2, glassBottom),
      Offset(bottomLeft + bottomWidth + 2, glassBottom),
      basePaint,
    );

    // ── Canudo (decorativo) ──
    final strawPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final strawStartX = w * 0.62;
    final strawEndX = w * 0.72;
    canvas.drawLine(
      Offset(strawStartX, glassTop - 4),
      Offset(strawEndX, glassBottom * 0.6),
      strawPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DrinkGlassPainter old) => true;
}
