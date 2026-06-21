import 'package:flutter/material.dart';
import '../theme/sd_theme.dart';

/// Botão principal em **pílula** com gradiente festivo e sombra suave.
///
/// (Mantém o nome `NeonButton` para não quebrar os imports das telas — o visual
/// agora é o da v0.4: cantos totalmente arredondados, sem glow neon.)
class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool expanded;
  final double height;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = SDColors.pink,
    this.expanded = false,
    this.height = 56,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final radius = widget.height / 2; // pílula

    Widget button = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    widget.color,
                    Color.lerp(widget.color, Colors.white, 0.18)!,
                  ],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: enabled && !_pressed
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        transform: _pressed
            ? Matrix4.diagonal3Values(0.97, 0.97, 1)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: enabled ? Colors.white : SDColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: enabled ? Colors.white : SDColors.textMuted,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
