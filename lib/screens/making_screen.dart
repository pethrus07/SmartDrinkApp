import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_models.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import 'dart:math' as math;

class MakingScreen extends StatelessWidget {
  const MakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    return Scaffold(
      backgroundColor: SDColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated ring
                _ProgressRing(progress: provider.makingProgress),
                const SizedBox(height: 32),

                // Status text
                Text(
                  'PREPARANDO SEU DRINK',
                  style: TextStyle(
                    color: SDColors.cyan,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '${(provider.makingProgress * 100).round()}%',
                  style: TextStyle(
                    color: SDColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                // Tempo restante
                Builder(builder: (context) {
                  final remainMs =
                      (provider.totalTimeMs * (1 - provider.makingProgress))
                          .round();
                  return Text(
                    '~${(remainMs / 1000).toStringAsFixed(1)}s restantes',
                    style: TextStyle(
                      color: SDColors.textMuted,
                      fontSize: 15,
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Command string (debug / dev)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SDColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SDColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'COMANDO ENVIADO',
                        style: TextStyle(
                          color: SDColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        provider.commandString,
                        style: TextStyle(
                          color: SDColors.green,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Válvulas ativas
                _ValveIndicators(
                  portions: provider.activePortion,
                  progress: provider.makingProgress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ANEL DE PROGRESSO ──────────────────────────────────────
class _ProgressRing extends StatefulWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 0.8 + (_pulseController.value * 0.4);
        return SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _RingPainter(
              progress: widget.progress,
              glowIntensity: pulse,
            ),
            child: Center(
              child: Icon(
                Icons.local_bar,
                color: SDColors.cyan.withOpacity(0.6 + widget.progress * 0.4),
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  _RingPainter({required this.progress, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background ring
    final bgPaint = Paint()
      ..color = SDColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: const [SDColors.cyan, SDColors.purple],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = SDColors.cyan.withOpacity(0.2 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}

// ─── INDICADORES DE VÁLVULA ─────────────────────────────────
class _ValveIndicators extends StatelessWidget {
  final List<DrinkPortion> portions;
  final double progress;

  const _ValveIndicators({
    required this.portions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numReservoirs, (i) {
        final reservoir = i + 1;
        final portion = portions.cast<DrinkPortion?>().firstWhere(
              (p) => p?.reservoir == reservoir,
              orElse: () => null,
            );
        final isActive = portion != null && portion.ml > 0;
        final ing = defaultIngredients[i];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 44,
          child: Column(
            children: [
              // LED indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? ing.color.withOpacity(0.2)
                      : SDColors.card,
                  border: Border.all(
                    color: isActive
                        ? ing.color
                        : SDColors.border,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: ing.color.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '$reservoir',
                    style: TextStyle(
                      color: isActive ? ing.color : SDColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isActive ? '${portion.timeMs}ms' : '0',
                style: TextStyle(
                  color: isActive ? ing.color : SDColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
