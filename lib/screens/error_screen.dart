import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/neon_button.dart';

/// Tela exibida quando o preparo falha (erro de comunicação ou falha
/// reportada pela máquina). Em operação real, orienta o cliente a
/// procurar o atendente — o reembolso/estorno entra junto com a
/// integração de pagamento real (ROADMAP).
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    return Scaffold(
      backgroundColor: SDColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SDColors.pink.withOpacity(0.12),
                      border: Border.all(color: SDColors.pink, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: SDColors.pink.withOpacity(0.35),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.priority_high,
                        color: SDColors.pink, size: 52),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'OPS, ALGO DEU ERRADO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SDColors.pink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage.isNotEmpty
                        ? provider.errorMessage
                        : 'Não foi possível preparar seu drink.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SDColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, procure o atendente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SDColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  NeonButton(
                    label: 'VOLTAR AO INÍCIO',
                    icon: Icons.home,
                    color: SDColors.cyan,
                    height: 52,
                    onPressed: () => provider.acknowledgeError(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
