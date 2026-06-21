import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/drink_models.dart';

/// Miniatura do drink: mostra a **foto** (quando o drink tem [DrinkPreset.imageData])
/// ou cai para a ilustração gerada do copo ([fallback]).
///
/// Decodifica o base64 uma única vez por imagem (cache em estado) para não
/// repintar a cada notificação do provider.
class DrinkThumb extends StatefulWidget {
  final DrinkPreset drink;
  final double size;
  final double radius;
  final Widget fallback;

  const DrinkThumb({
    super.key,
    required this.drink,
    required this.size,
    required this.fallback,
    this.radius = 16,
  });

  @override
  State<DrinkThumb> createState() => _DrinkThumbState();
}

class _DrinkThumbState extends State<DrinkThumb> {
  Uint8List? _bytes;
  String? _decodedFrom;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(DrinkThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.drink.imageData != _decodedFrom) _decode();
  }

  void _decode() {
    _decodedFrom = widget.drink.imageData;
    _bytes = widget.drink.imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: widget.fallback),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Image.memory(
        _bytes!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
