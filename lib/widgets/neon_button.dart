import 'package:flutter/material.dart';
import '../theme/sd_theme.dart';

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
    this.color = SDColors.cyan,
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
                    widget.color.withOpacity(0.7),
                  ],
                )
              : null,
          color: enabled ? null : SDColors.border,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled && !_pressed
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        transform: _pressed ? Matrix4.identity()..scale(0.97) : Matrix4.identity(),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: enabled ? SDColors.bg : SDColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: enabled ? SDColors.bg : SDColors.textMuted,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
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
