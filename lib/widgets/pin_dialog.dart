import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';

/// Diálogo de PIN (4 dígitos) protegendo o painel admin.
/// Retorna `true` via `Navigator.pop` quando o PIN confere.
class PinDialog extends StatefulWidget {
  const PinDialog({super.key});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  String _input = '';
  bool _wrong = false;

  void _press(String digit) {
    if (_input.length >= 4) return;
    setState(() {
      _wrong = false;
      _input += digit;
    });
    if (_input.length == 4) _check();
  }

  void _erase() {
    if (_input.isEmpty) return;
    setState(() {
      _wrong = false;
      _input = _input.substring(0, _input.length - 1);
    });
  }

  void _check() {
    final pin = context.read<DrinkProvider>().adminPin;
    if (_input == pin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _wrong = true;
        _input = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SDColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SDColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: SDColors.orange, size: 28),
              const SizedBox(height: 10),
              Text(
                'ACESSO RESTRITO',
                style: TextStyle(
                  color: SDColors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 18),

              // Indicadores de dígito
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _input.length;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? (_wrong ? SDColors.pink : SDColors.cyan)
                          : Colors.transparent,
                      border: Border.all(
                        color: _wrong
                            ? SDColors.pink
                            : (filled ? SDColors.cyan : SDColors.border),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 18,
                child: _wrong
                    ? Text(
                        'PIN incorreto',
                        style:
                            TextStyle(color: SDColors.pink, fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(height: 10),

              // Teclado numérico
              for (final row in const [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', '<'],
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    if (key.isEmpty) {
                      return const SizedBox(width: 84, height: 68);
                    }
                    final isErase = key == '<';
                    return Padding(
                      padding: const EdgeInsets.all(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isErase ? _erase : () => _press(key),
                        child: Container(
                          width: 72,
                          height: 56,
                          decoration: BoxDecoration(
                            color: SDColors.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: SDColors.border),
                          ),
                          child: Center(
                            child: isErase
                                ? const Icon(Icons.backspace_outlined,
                                    color: SDColors.textSecondary, size: 20)
                                : Text(
                                    key,
                                    style: TextStyle(
                                      color: SDColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: SDColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
