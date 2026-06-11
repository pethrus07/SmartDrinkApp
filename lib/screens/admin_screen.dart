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
                      return _ReservoirCard(
                        ingredient: ing,
                        level: level,
                        onRefill: () =>
                            provider.refillReservoir(ing.reservoir),
                        onRename: () =>
                            _showRenameDialog(context, provider, ing),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ── Seção: Estatísticas ──
                    _SectionTitle(
                        title: 'ESTATÍSTICAS', icon: Icons.bar_chart),
                    const SizedBox(height: 12),
                    _StatsSection(provider: provider),
                    const SizedBox(height: 24),

                    // ── Seção: Venda & Simulação ──
                    _SectionTitle(
                        title: 'VENDA & SIMULAÇÃO', icon: Icons.attach_money),
                    const SizedBox(height: 12),
                    _SaleSimulationSection(provider: provider),
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
  final VoidCallback onRefill;
  final VoidCallback onRename;

  const _ReservoirCard({
    required this.ingredient,
    required this.level,
    required this.onRefill,
    required this.onRename,
  });

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

          // Nome (toque para renomear)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRename,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          ingredient.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SDColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit,
                          color: SDColors.textMuted, size: 13),
                    ],
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
          const SizedBox(width: 10),

          // Reabastecer (simulado nesta versão)
          GestureDetector(
            onTap: level >= 2 ? null : onRefill,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SDColors.cyan
                    .withOpacity(level >= 2 ? 0.04 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        SDColors.cyan.withOpacity(level >= 2 ? 0.15 : 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.opacity,
                      color: SDColors.cyan
                          .withOpacity(level >= 2 ? 0.4 : 1),
                      size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'REABASTECER',
                    style: TextStyle(
                      color: SDColors.cyan
                          .withOpacity(level >= 2 ? 0.4 : 1),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DIÁLOGO DE RENOMEAR RESERVATÓRIO ───────────────────────
Future<void> _showRenameDialog(
  BuildContext context,
  DrinkProvider provider,
  Ingredient ingredient,
) async {
  final controller = TextEditingController(text: ingredient.name);
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SDColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SDColors.border),
      ),
      title: Text(
        'Reservatório ${ingredient.reservoir}',
        style: TextStyle(color: SDColors.textPrimary, fontSize: 18),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 24,
        style: TextStyle(color: SDColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'Nome da bebida',
          labelStyle: TextStyle(color: SDColors.textMuted),
          counterStyle: TextStyle(color: SDColors.textMuted),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: SDColors.border),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child:
              Text('Cancelar', style: TextStyle(color: SDColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: Text('Salvar', style: TextStyle(color: SDColors.cyan)),
        ),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) {
    provider.renameIngredient(ingredient.reservoir, name);
  }
}

// ─── SEÇÃO ESTATÍSTICAS ─────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final DrinkProvider provider;
  const _StatsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalMl = provider.mlServedByReservoir.values
        .fold<int>(0, (s, v) => s + v);
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
          Row(
            children: [
              _StatBox(
                label: 'DRINKS SERVIDOS',
                value: '${provider.drinksServed}',
                color: SDColors.cyan,
              ),
              const SizedBox(width: 12),
              _StatBox(
                label: 'VOLUME TOTAL',
                value: totalMl >= 1000
                    ? '${(totalMl / 1000).toStringAsFixed(1)} L'
                    : '$totalMl ml',
                color: SDColors.purple,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => provider.resetStats(),
                icon: Icon(Icons.restart_alt,
                    color: SDColors.textMuted, size: 16),
                label: Text('Zerar',
                    style:
                        TextStyle(color: SDColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.mlServedByReservoir.entries.map((e) {
            final ing = ingredientFor(e.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ing.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ing.name,
                      style: TextStyle(
                          color: SDColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${e.value} ml',
                    style: TextStyle(
                      color: SDColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: SDColors.textMuted,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SEÇÃO VENDA & SIMULAÇÃO ────────────────────────────────
class _SaleSimulationSection extends StatelessWidget {
  final DrinkProvider provider;
  const _SaleSimulationSection({required this.provider});

  String get _price {
    final cents = provider.drinkPriceCents;
    return 'R\$ ${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
  }

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
        children: [
          // Preço do drink
          Row(
            children: [
              Icon(Icons.sell, color: SDColors.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Preço por drink',
                  style:
                      TextStyle(color: SDColors.textSecondary, fontSize: 14),
                ),
              ),
              _RoundIconButton(
                icon: Icons.remove,
                onTap: () => provider.setDrinkPriceCents(
                    provider.drinkPriceCents - 100),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _price,
                  style: TextStyle(
                    color: SDColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _RoundIconButton(
                icon: Icons.add,
                onTap: () => provider.setDrinkPriceCents(
                    provider.drinkPriceCents + 100),
              ),
            ],
          ),
          const Divider(color: SDColors.border, height: 24),

          // Simular falha
          Row(
            children: [
              Icon(Icons.science, color: SDColors.pink, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simular falha no próximo drink',
                      style: TextStyle(
                          color: SDColors.textSecondary, fontSize: 14),
                    ),
                    Text(
                      'Demonstra a tela de erro para o cliente',
                      style:
                          TextStyle(color: SDColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.simulateNextFailure,
                activeColor: SDColors.pink,
                onChanged: (_) => provider.toggleSimulateFailure(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SDColors.bg,
          border: Border.all(color: SDColors.border),
        ),
        child: Icon(icon, color: SDColors.textSecondary, size: 18),
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

// ─── CALIBRAGEM (editável) ──────────────────────────────────
class _CalibrationInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    Widget stepperRow({
      required String label,
      required String hint,
      required int value,
      required String unit,
      required void Function(int) onChanged,
      required int step,
    }) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: SDColors.textSecondary, fontSize: 14)),
                Text(hint,
                    style:
                        TextStyle(color: SDColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.remove,
            onTap: () => onChanged(value - step),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value $unit',
              style: TextStyle(
                color: SDColors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onTap: () => onChanged(value + step),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SDColors.yellow.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          stepperRow(
            label: 'Tempo por ml',
            hint: 'Quanto tempo a válvula fica aberta por ml',
            value: msPerMl,
            unit: 'ms/ml',
            step: 1,
            onChanged: (v) => provider.setCalibration(msPerMlValue: v),
          ),
          const Divider(color: SDColors.border, height: 24),
          stepperRow(
            label: 'Tempo de abertura',
            hint: 'Overhead fixo por acionamento de válvula',
            value: valveOpenMs,
            unit: 'ms',
            step: 10,
            onChanged: (v) => provider.setCalibration(valveOpenMsValue: v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: SDColors.yellow, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fórmula: tempo = (ml × $msPerMl ms) + $valveOpenMs ms. '
                  'Os ajustes valem para todos os drinks e ficam salvos.',
                  style: TextStyle(color: SDColors.textMuted, fontSize: 11),
                ),
              ),
            ],
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
