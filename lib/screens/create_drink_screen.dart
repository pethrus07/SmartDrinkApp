import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_models.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../util/image_pick.dart';
import '../widgets/cup_widget.dart';
import '../widgets/neon_button.dart';
import '../widgets/drink_illustration.dart';

/// Dialog/Bottom sheet para o owner criar um novo drink preset
class CreateDrinkDialog extends StatefulWidget {
  const CreateDrinkDialog({super.key});

  @override
  State<CreateDrinkDialog> createState() => _CreateDrinkDialogState();
}

class _CreateDrinkDialogState extends State<CreateDrinkDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final List<DrinkPortion> _portions = [];
  String? _imageData;
  bool _pickingImage = false;

  int get _totalMl => _portions.fold(0, (s, p) => s + p.ml);
  int get _totalTimeMs => _portions.fold(0, (s, p) => s + p.timeMs);
  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _totalMl > 0 &&
      _totalMl <= cupMl;

  void _addIngredient(int reservoir) {
    if (_portions.any((p) => p.reservoir == reservoir)) return;
    setState(() {
      _portions.add(DrinkPortion(reservoir: reservoir, ml: 40));
    });
  }

  void _removeIngredient(int reservoir) {
    setState(() {
      _portions.removeWhere((p) => p.reservoir == reservoir);
    });
  }

  void _updateMl(int reservoir, int ml) {
    setState(() {
      final idx = _portions.indexWhere((p) => p.reservoir == reservoir);
      if (idx == -1) return;
      final othersTotal = _portions
          .where((p) => p.reservoir != reservoir)
          .fold(0, (s, p) => s + p.ml);
      final maxForThis = cupMl - othersTotal;
      _portions[idx] = DrinkPortion(
        reservoir: reservoir,
        ml: ml.clamp(0, maxForThis),
      );
    });
  }

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final data = await pickDrinkImageBase64();
      if (data != null && mounted) setState(() => _imageData = data);
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _save() {
    if (!_isValid) return;
    final provider = context.read<DrinkProvider>();
    provider.saveDrink(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? _portions
              .map((p) {
                final ing = defaultIngredients.firstWhere(
                  (i) => i.reservoir == p.reservoir,
                  orElse: () => defaultIngredients[0],
                );
                return ing.name;
              })
              .join(' + ')
          : _descController.text.trim(),
      portions: _portions
          .map((p) => DrinkPortion(reservoir: p.reservoir, ml: p.ml))
          .toList(),
      imageData: _imageData,
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usedReservoirs = _portions.map((p) => p.reservoir).toSet();
    final available = defaultIngredients
        .where((i) => !usedReservoirs.contains(i.reservoir))
        .toList();

    return Dialog(
      backgroundColor: SDColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Row(
                children: [
                  const Icon(Icons.add_circle, color: SDColors.purple, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Novo drink',
                    style: TextStyle(
                      color: SDColors.purple,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: SDColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Formulário ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome
                      _InputField(
                        controller: _nameController,
                        label: 'Nome do Drink',
                        hint: 'Ex: Sunset Paradise',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // Descrição (opcional)
                      _InputField(
                        controller: _descController,
                        label: 'Descrição (opcional)',
                        hint: 'Auto-gerada se vazio',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Foto do drink (opcional)
                      _ImagePickerField(
                        imageData: _imageData,
                        busy: _pickingImage,
                        onPick: _pickImage,
                        onRemove: () => setState(() => _imageData = null),
                      ),
                      const SizedBox(height: 20),

                      // ── Preview ──
                      if (_portions.isNotEmpty)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DrinkIllustration(portions: _portions, size: 64),
                              const SizedBox(width: 16),
                              CupWidget(
                                portions: _portions,
                                height: 120,
                                width: 75,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_totalMl}ml',
                                    style: TextStyle(
                                      color: _totalMl > cupMl
                                          ? SDColors.pink
                                          : SDColors.cyan,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${(_totalTimeMs / 1000).toStringAsFixed(1)}s',
                                    style: TextStyle(
                                      color: SDColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ── Ingredientes adicionados ──
                      ..._portions.map((portion) {
                        final ing = defaultIngredients.firstWhere(
                          (i) => i.reservoir == portion.reservoir,
                          orElse: () => defaultIngredients[0],
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: SDColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ing.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: ing.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  ing.name,
                                  style: TextStyle(
                                    color: SDColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: ing.color,
                                    thumbColor: ing.color,
                                    trackHeight: 6,
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                            enabledThumbRadius: 10),
                                  ),
                                  child: Slider(
                                    value: portion.ml.toDouble(),
                                    min: 0,
                                    max: cupMl.toDouble(),
                                    divisions: cupMl ~/ 10,
                                    onChanged: (v) =>
                                        _updateMl(ing.reservoir, v.round()),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 55,
                                child: Text(
                                  '${portion.ml}ml',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: ing.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeIngredient(ing.reservoir),
                                child: Icon(Icons.close,
                                    color: SDColors.pink, size: 18),
                              ),
                            ],
                          ),
                        );
                      }),

                      // ── Adicionar ingrediente ──
                      if (available.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            color: SDColors.textMuted,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: available.map((ing) {
                            return GestureDetector(
                              onTap: () => _addIngredient(ing.reservoir),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: ing.color.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add,
                                        color: ing.color, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      ing.name,
                                      style: TextStyle(
                                        color: ing.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Botão salvar ──
              NeonButton(
                label: 'Salvar drink',
                icon: Icons.save,
                color: SDColors.green,
                expanded: true,
                onPressed: _isValid ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Campo de foto do drink ─────────────────────────────────
class _ImagePickerField extends StatelessWidget {
  final String? imageData;
  final bool busy;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerField({
    required this.imageData,
    required this.busy,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageData != null && imageData!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview (ou placeholder) tocável.
        GestureDetector(
          onTap: busy ? null : onPick,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: SDColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SDColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: busy
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : hasImage
                    ? Image.memory(base64Decode(imageData!), fit: BoxFit.cover)
                    : Icon(Icons.add_a_photo_outlined,
                        color: SDColors.textMuted, size: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto do drink (opcional)',
                style: TextStyle(
                  color: SDColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : onPick,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(hasImage ? 'Trocar foto' : 'Adicionar foto'),
                    style: TextButton.styleFrom(
                      foregroundColor: SDColors.cyan,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  if (hasImage)
                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remover'),
                      style: TextButton.styleFrom(
                        foregroundColor: SDColors.pink,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: SDColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: SDColors.textMuted, fontSize: 13),
        hintStyle: TextStyle(color: SDColors.textMuted.withValues(alpha: 0.5)),
        filled: true,
        fillColor: SDColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SDColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SDColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SDColors.cyan),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
