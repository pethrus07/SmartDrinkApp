import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/neon_button.dart';

/// Tela de conclusão ("pode pegar seu copo"): celebra o fim do preparo com uma
/// animação e oferece voltar ao início para um novo pedido.
class DoneScreen extends StatefulWidget {
  const DoneScreen({super.key});

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _controller.forward();

    // Auto-return after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        context.read<DrinkProvider>().goHome();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _opacityAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Check icon com glow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: SDColors.glowMix,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SDColors.cyan.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: SDColors.purple.withValues(alpha: 0.3),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Text(
                          'SEU DRINK ESTÁ PRONTO!',
                          style: TextStyle(
                            color: SDColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Retire seu copo e aproveite 🍹',
                          style: TextStyle(
                            color: SDColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mostrar string final
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: SDColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SDColors.border),
                          ),
                          child: SelectableText(
                            provider.commandString,
                            style: TextStyle(
                              color: SDColors.green,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 48),

                        NeonButton(
                          label: 'Novo drink',
                          icon: Icons.refresh,
                          color: SDColors.cyan,
                          onPressed: () => provider.goHome(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
