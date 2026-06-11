import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/drink_models.dart';
import '../theme/sd_theme.dart';

class CupWidget extends StatefulWidget {
  final List<DrinkPortion> portions;
  final double maxMl;
  final double height;
  final double width;
  final bool animate;

  const CupWidget({
    super.key,
    required this.portions,
    this.maxMl = 400,
    this.height = 280,
    this.width = 160,
    this.animate = true,
  });

  @override
  State<CupWidget> createState() => _CupWidgetState();
}

class _CupWidgetState extends State<CupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMl = widget.portions.fold(0, (s, p) => s + p.ml);
    final fillRatio = (totalMl / widget.maxMl).clamp(0.0, 1.0);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return CustomPaint(
            painter: _CupPainter(
              portions: widget.portions,
              maxMl: widget.maxMl,
              fillRatio: fillRatio,
              wavePhase: _waveController.value * 2 * math.pi,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  final List<DrinkPortion> portions;
  final double maxMl;
  final double fillRatio;
  final double wavePhase;

  _CupPainter({
    required this.portions,
    required this.maxMl,
    required this.fillRatio,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = 12.0;

    // Cup outline (trapezoid shape)
    final cupTop = 20.0;
    final cupBottom = h - 10;
    final topWidth = w - margin * 2;
    final bottomWidth = w * 0.65;
    final topLeft = (w - topWidth) / 2;
    final bottomLeft = (w - bottomWidth) / 2;

    // Cup path
    final cupPath = Path()
      ..moveTo(topLeft, cupTop)
      ..lineTo(bottomLeft, cupBottom)
      ..lineTo(bottomLeft + bottomWidth, cupBottom)
      ..lineTo(topLeft + topWidth, cupTop)
      ..close();

    // Clip to cup shape for fills
    canvas.save();
    canvas.clipPath(cupPath);

    // Draw ingredient layers from bottom to top
    if (portions.isNotEmpty && fillRatio > 0) {
      final totalMl = portions.fold(0, (s, p) => s + p.ml);
      final fillHeight = (cupBottom - cupTop) * fillRatio;
      var currentBottom = cupBottom;

      for (final portion in portions) {
        if (portion.ml <= 0) continue;
        final layerRatio = portion.ml / totalMl;
        final layerHeight = fillHeight * layerRatio;
        final layerTop = currentBottom - layerHeight;

        final ing = defaultIngredients.firstWhere(
          (i) => i.reservoir == portion.reservoir,
          orElse: () => defaultIngredients[0],
        );

        // Layer fill
        final layerPaint = Paint()
          ..color = ing.color.withOpacity(0.7)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTRB(0, layerTop, w, currentBottom),
          layerPaint,
        );

        // Subtle gradient overlay
        final gradPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ing.color.withOpacity(0.3),
              ing.color.withOpacity(0.1),
            ],
          ).createShader(Rect.fromLTRB(0, layerTop, w, currentBottom));
        canvas.drawRect(
          Rect.fromLTRB(0, layerTop, w, currentBottom),
          gradPaint,
        );

        currentBottom = layerTop;
      }

      // Wave on top of liquid
      if (fillRatio > 0.01) {
        final waveTop = cupBottom - fillHeight;
        final wavePaint = Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.fill;

        final wavePath = Path();
        wavePath.moveTo(0, waveTop);
        for (double x = 0; x <= w; x += 1) {
          final y = waveTop +
              math.sin((x / w) * 4 * math.pi + wavePhase) * 3 +
              math.sin((x / w) * 2 * math.pi + wavePhase * 0.7) * 2;
          wavePath.lineTo(x, y);
        }
        wavePath.lineTo(w, waveTop + 10);
        wavePath.lineTo(0, waveTop + 10);
        wavePath.close();
        canvas.drawPath(wavePath, wavePaint);
      }
    }

    canvas.restore();

    // Cup outline stroke
    final outlinePaint = Paint()
      ..color = SDColors.cyan.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(cupPath, outlinePaint);

    // Glow effect on outline
    final glowPaint = Paint()
      ..color = SDColors.cyan.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(cupPath, glowPaint);

    // "400ml" label on top
    final labelPainter = TextPainter(
      text: TextSpan(
        text: '${maxMl.toInt()}ml',
        style: TextStyle(
          color: SDColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset((w - labelPainter.width) / 2, 2));
  }

  @override
  bool shouldRepaint(covariant _CupPainter old) =>
      old.fillRatio != fillRatio ||
      old.wavePhase != wavePhase ||
      old.portions != portions;
}
