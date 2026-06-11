import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_models.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/drink_illustration.dart';
import 'create_drink_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    return Scaffold(
      backgroundColor: SDColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.goBack(),
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
                    'CONFIGURAÇÕES',
                    style: TextStyle(
                      color: SDColors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SDColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SDColors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      'OWNER',
                      style: TextStyle(
                        color: SDColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // ── Seção: Gerenciar Drinks ──
                    _SectionTitle(title: 'GERENCIAR DRINKS', icon: Icons.local_bar),
                    const SizedBox(height: 12),
                    _DrinkManagerSection(provider: provider),
                    const SizedBox(height: 24),

                    // ── Seção: Reservatórios ──
                    _SectionTitle(title: 'RESERVATÓRIOS', icon: Icons.water_drop),
                    const SizedBox(height: 12),

                    ...defaultIngredients.map((ing) {
                      final level = provider.reservoirLevels[ing.reservoir] ?? 0;
                      return _ReservoirCard(ingredient: ing, level: level);
                    }),

                    const SizedBox(height: 24),

                    // ── Seção: Protocolo ──
                    _SectionTitle(
                        title: 'PROTOCOLO DE COMUNICAÇÃO', icon: Icons.code),
                    const SizedBox(height: 12),
                    _ProtocolInfo(),

                    const SizedBox(height: 24),

                    // ── Seção: Calibragem ──
                    _SectionTitle(title: 'CALIBRAGEM', icon: Icons.tune),
                    const SizedBox(height: 12),
                    _CalibrationInfo(),

                    const SizedBox(height: 24),

                    // ── Seção: Testes ──
                    _SectionTitle(title: 'TESTE DE VÁLVULAS', icon: Icons.science),
                    const SizedBox(height: 12),
                    _ValveTestPanel(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TÍTULO DE SEÇÃO ────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: SDColors.textMuted, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: SDColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: SDColors.border),
        ),
      ],
    );
  }
}

// ─── CARD DE RESERVATÓRIO ───────────────────────────────────
class _ReservoirCard extends StatelessWidget {
  final Ingredient ingredient;
  final int level;

  const _ReservoirCard({required this.ingredient, required this.level});

  String get _levelLabel {
    switch (level) {
      case 0:
        return 'VAZIO';
      case 1:
        return 'BAIXO';
      case 2:
        return 'OK';
      case 3:
        return 'CHEIO';
      default:
        return '?';
    }
  }

  Color get _levelColor {
    switch (level) {
      case 0:
        return SDColors.pink;
      case 1:
        return SDColors.orange;
      case 2:
        return SDColors.green;
      case 3:
        return SDColors.cyan;
      default:
        return SDColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SDColors.border),
      ),
      child: Row(
        children: [
          // Número do reservatório
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ingredient.color.withOpacity(0.15),
              border: Border.all(color: ingredient.color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                '${ingredient.reservoir}',
                style: TextStyle(
                  color: ingredient.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Nome
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: TextStyle(
                    color: SDColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Reservatório ${ingredient.reservoir}',
                  style: TextStyle(
                    color: SDColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _levelColor.withOpacity(0.4)),
            ),
            child: Text(
              _levelLabel,
              style: TextStyle(
                color: _levelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INFO DO PROTOCOLO ──────────────────────────────────────
class _ProtocolInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SDColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Fazer drink',
            value: '#SD;1:ms;2:ms;3:ms;4:ms;5:ms;6:ms;/SD',
            color: SDColors.green,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Solicitar nível',
            value: '#SD;level;/SD',
            color: SDColors.cyan,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Resposta nível',
            value: '#SD;1:N;2:N;3:N;4:N;5:N;6:N;/SD',
            color: SDColors.purple,
          ),
          const Divider(color: SDColors.border, height: 24),
          _InfoRow(
            label: 'Fórmula',
            value: 'tempo = (ML × 30ms) + 100ms abertura',
            color: SDColors.orange,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Copo',
            value: '400ml máximo',
            color: SDColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              color: SDColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── INFO CALIBRAGEM ────────────────────────────────────────
class _CalibrationInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SDColors.yellow.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: SDColors.yellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sistema de calibragem das válvulas será integrado futuramente. '
              'Valores atuais: 30ms/ml + 100ms abertura.',
              style: TextStyle(
                color: SDColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAINEL DE TESTE DE VÁLVULAS ────────────────────────────
class _ValveTestPanel extends StatefulWidget {
  @override
  State<_ValveTestPanel> createState() => _ValveTestPanelState();
}

class _ValveTestPanelState extends State<_ValveTestPanel> {
  int _testMl = 50;
  String? _lastCommand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SDColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantidade de teste: ${_testMl}ml (${(_testMl * msPerMl) + valveOpenMs}ms)',
            style: TextStyle(
              color: SDColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          Slider(
            value: _testMl.toDouble(),
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (v) => setState(() => _testMl = v.round()),
          ),
          const SizedBox(height: 12),

          // Botões por reservatório
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(numReservoirs, (i) {
              final reservoir = i + 1;
              final ing = defaultIngredients[i];
              return GestureDetector(
                onTap: () {
                  final provider = context.read<DrinkProvider>();
                  provider.testValve(reservoir, _testMl).then((cmd) {
                    if (mounted) setState(() => _lastCommand = cmd);
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ing.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ing.color.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'V$reservoir',
                        style: TextStyle(
                          color: ing.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ing.name,
                        style: TextStyle(
                          color: ing.color.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          if (_lastCommand != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SDColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.send, color: SDColors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      _lastCommand!,
                      style: TextStyle(
                        color: SDColors.green,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── SEÇÃO GERENCIAR DRINKS ─────────────────────────────────
class _DrinkManagerSection extends StatelessWidget {
  final DrinkProvider provider;
  const _DrinkManagerSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botão criar novo
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const CreateDrinkDialog(),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SDColors.purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SDColors.purple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: SDColors.purple, size: 22),
                const SizedBox(width: 10),
                Text(
                  'CRIAR NOVO DRINK',
                  style: TextStyle(
                    color: SDColors.purple,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info
        const SizedBox(height: 12),
        Text(
          '${presetDrinks.length} drinks padrão + ${provider.userDrinks.length} customizados',
          style: TextStyle(color: SDColors.textMuted, fontSize: 12),
        ),

        // Lista de drinks customizados
        if (provider.userDrinks.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...provider.userDrinks.map((drink) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: SDColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SDColors.border),
              ),
              child: Row(
                children: [
                  DrinkIllustration(portions: drink.portions, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drink.name,
                          style: TextStyle(
                            color: SDColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${drink.totalMl}ml · ${drink.description}',
                          style: TextStyle(
                            color: SDColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(drink.totalTimeMs / 1000).toStringAsFixed(1)}s',
                    style: TextStyle(
                      color: SDColors.cyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => provider.deleteDrink(drink.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: SDColors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: SDColors.pink, size: 18),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
