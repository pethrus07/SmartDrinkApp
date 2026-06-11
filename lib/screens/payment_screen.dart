import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/neon_button.dart';

/// Tela de pagamento — SIMULADA nesta versão.
///
/// Demonstra o fluxo previsto no escopo: escolher Pix ou cartão,
/// "aguardar" a aprovação e seguir para o preparo. A integração real
/// (gateway Pix / maquininha) está no ROADMAP.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _PayMethod { pix, card }

enum _PayPhase { choosing, waiting, approved }

class _PaymentScreenState extends State<PaymentScreen> {
  _PayMethod? _method;
  _PayPhase _phase = _PayPhase.choosing;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _choose(_PayMethod method) {
    setState(() {
      _method = method;
      _phase = _PayPhase.waiting;
    });
    // Aprovação automática simulada após alguns segundos.
    _timer = Timer(const Duration(milliseconds: 3200), _approve);
  }

  void _approve() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _phase = _PayPhase.approved);
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) context.read<DrinkProvider>().confirmPayment();
    });
  }

  String _formatPrice(int cents) {
    final reais = cents ~/ 100;
    final c = (cents % 100).toString().padLeft(2, '0');
    return 'R\$ $reais,$c';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();
    final price = _formatPrice(provider.drinkPriceCents);

    return Scaffold(
      backgroundColor: SDColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Header ──
              Row(
                children: [
                  if (_phase == _PayPhase.choosing)
                    GestureDetector(
                      onTap: () => provider.cancelPayment(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SDColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SDColors.border),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: SDColors.textSecondary, size: 22),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Text(
                    'PAGAMENTO',
                    style: TextStyle(
                      color: SDColors.cyan,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SDColors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: SDColors.yellow.withOpacity(0.4)),
                    ),
                    child: Text(
                      'SIMULAÇÃO',
                      style: TextStyle(
                        color: SDColors.yellow,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: switch (_phase) {
                      _PayPhase.choosing => _ChoosePanel(
                          price: price,
                          onChoose: _choose,
                        ),
                      _PayPhase.waiting => _WaitingPanel(
                          method: _method!,
                          price: price,
                          onSimulateApproval: _approve,
                          onCancel: () {
                            _timer?.cancel();
                            setState(() {
                              _phase = _PayPhase.choosing;
                              _method = null;
                            });
                          },
                        ),
                      _PayPhase.approved => const _ApprovedPanel(),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ESCOLHA DO MÉTODO ──────────────────────────────────────
class _ChoosePanel extends StatelessWidget {
  final String price;
  final void Function(_PayMethod) onChoose;

  const _ChoosePanel({required this.price, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TOTAL A PAGAR',
          style: TextStyle(
            color: SDColors.textMuted,
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: TextStyle(
            color: SDColors.textPrimary,
            fontSize: 52,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MethodCard(
              icon: Icons.qr_code_2,
              label: 'PIX',
              color: SDColors.green,
              onTap: () => onChoose(_PayMethod.pix),
            ),
            const SizedBox(width: 20),
            _MethodCard(
              icon: Icons.credit_card,
              label: 'CARTÃO',
              color: SDColors.purple,
              onTap: () => onChoose(_PayMethod.card),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 160,
        decoration: BoxDecoration(
          color: SDColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 52),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AGUARDANDO PAGAMENTO ───────────────────────────────────
class _WaitingPanel extends StatelessWidget {
  final _PayMethod method;
  final String price;
  final VoidCallback onSimulateApproval;
  final VoidCallback onCancel;

  const _WaitingPanel({
    required this.method,
    required this.price,
    required this.onSimulateApproval,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPix = method == _PayMethod.pix;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPix) ...[
          // "QR Code" decorativo da simulação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              size: const Size(150, 150),
              painter: _FakeQrPainter(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Escaneie o QR Code para pagar $price',
            style: TextStyle(color: SDColors.textSecondary, fontSize: 15),
          ),
        ] else ...[
          Icon(Icons.contactless, color: SDColors.purple, size: 84),
          const SizedBox(height: 20),
          Text(
            'Aproxime ou insira o cartão · $price',
            style: TextStyle(color: SDColors.textSecondary, fontSize: 15),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: SDColors.card,
            color: isPix ? SDColors.green : SDColors.purple,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'AGUARDANDO PAGAMENTO...',
          style: TextStyle(
            color: SDColors.textMuted,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeonButton(
              label: 'CANCELAR',
              icon: Icons.close,
              color: SDColors.pink,
              height: 46,
              onPressed: onCancel,
            ),
            const SizedBox(width: 14),
            // Atalho de demo: não esperar os 3s da simulação.
            NeonButton(
              label: 'SIMULAR APROVAÇÃO',
              icon: Icons.check,
              color: SDColors.green,
              height: 46,
              onPressed: onSimulateApproval,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── PAGAMENTO APROVADO ─────────────────────────────────────
class _ApprovedPanel extends StatelessWidget {
  const _ApprovedPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SDColors.green.withOpacity(0.12),
            border: Border.all(color: SDColors.green, width: 2),
            boxShadow: [
              BoxShadow(
                color: SDColors.green.withOpacity(0.35),
                blurRadius: 30,
              ),
            ],
          ),
          child: const Icon(Icons.check, color: SDColors.green, size: 56),
        ),
        const SizedBox(height: 22),
        Text(
          'PAGAMENTO APROVADO',
          style: TextStyle(
            color: SDColors.green,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preparando seu drink...',
          style: TextStyle(color: SDColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }
}

/// QR Code decorativo (padrão pseudo-aleatório estável) — apenas visual
/// da simulação; não codifica nada.
class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111111);
    const n = 21;
    final cell = size.width / n;
    final rnd = math.Random(42);

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final inFinder = (x < 7 && y < 7) ||
            (x >= n - 7 && y < 7) ||
            (x < 7 && y >= n - 7);
        if (inFinder) continue;
        if (rnd.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            paint,
          );
        }
      }
    }

    void finder(double ox, double oy) {
      canvas.drawRect(Rect.fromLTWH(ox, oy, cell * 7, cell * 7), paint);
      canvas.drawRect(
        Rect.fromLTWH(ox + cell, oy + cell, cell * 5, cell * 5),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(ox + cell * 2, oy + cell * 2, cell * 3, cell * 3),
        paint,
      );
    }

    finder(0, 0);
    finder(size.width - cell * 7, 0);
    finder(0, size.height - cell * 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
