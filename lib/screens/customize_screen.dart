import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_models.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/cup_widget.dart';
import '../widgets/neon_button.dart';

/// Tela de montar/ajustar o drink: sliders por reservatório com percentuais ao
/// vivo e trava no volume do copo, adicionar/remover ingredientes e seguir para
/// o pagamento. Opera sobre as porções em edição do [DrinkProvider].
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();
    final portions = provider.customPortions;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Header ──
              _CustomizeHeader(provider: provider),
              const SizedBox(height: 16),

              // ── Corpo ──
              Expanded(
                child: isLandscape
                    ? _LandscapeBody(provider: provider, portions: portions)
                    : _PortraitBody(provider: provider, portions: portions),
              ),

              const SizedBox(height: 12),

              // ── Footer com info + botão ──
              _CustomizeFooter(provider: provider),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HEADER ─────────────────────────────────────────────────
class _CustomizeHeader extends StatelessWidget {
  final DrinkProvider provider;
  const _CustomizeHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            child: const Icon(Icons.arrow_back, color: SDColors.textSecondary, size: 22),
          ),
        ),
        const SizedBox(width: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [SDColors.purple, SDColors.cyan],
          ).createShader(bounds),
          child: Text(
            'Personalizar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 3,
                ),
          ),
        ),
        const Spacer(),
        // Indicador de volume
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: SDColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: provider.totalMl > cupMl
                  ? SDColors.pink
                  : SDColors.cyan.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${provider.totalMl} / ${cupMl}ml',
            style: TextStyle(
              color: provider.totalMl > cupMl ? SDColors.pink : SDColors.cyan,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── LANDSCAPE BODY ─────────────────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final DrinkProvider provider;
  final List<DrinkPortion> portions;

  const _LandscapeBody({required this.provider, required this.portions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sliders à esquerda
        Expanded(
          flex: 3,
          child: _SlidersList(provider: provider, portions: portions),
        ),
        const SizedBox(width: 20),

        // Copo à direita
        SizedBox(
          width: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupWidget(
                portions: portions,
                height: 260,
                width: 150,
              ),
              const SizedBox(height: 16),
              _PortionSummary(portions: portions),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── PORTRAIT BODY ──────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final DrinkProvider provider;
  final List<DrinkPortion> portions;

  const _PortraitBody({required this.provider, required this.portions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Copo compacto
        CupWidget(
          portions: portions,
          height: 140,
          width: 90,
        ),
        const SizedBox(height: 16),
        // Sliders
        Expanded(
          child: _SlidersList(provider: provider, portions: portions),
        ),
      ],
    );
  }
}

// ─── LISTA DE SLIDERS ───────────────────────────────────────
class _SlidersList extends StatelessWidget {
  final DrinkProvider provider;
  final List<DrinkPortion> portions;

  const _SlidersList({required this.provider, required this.portions});

  @override
  Widget build(BuildContext context) {
    // Ingredientes disponíveis para adicionar
    final usedReservoirs = portions.map((p) => p.reservoir).toSet();
    // Reservatórios vazios não podem ser adicionados ao drink.
    final available = defaultIngredients
        .where((i) =>
            !usedReservoirs.contains(i.reservoir) &&
            !provider.isReservoirEmpty(i.reservoir))
        .toList();

    return ListView(
      children: [
        // Sliders ativos
        ...portions.map((portion) {
          final ing = defaultIngredients.firstWhere(
            (i) => i.reservoir == portion.reservoir,
            orElse: () => defaultIngredients[0],
          );
          return _IngredientSlider(
            ingredient: ing,
            portion: portion,
            provider: provider,
          );
        }),

        // Botão de adicionar ingrediente
        if (available.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AddIngredientRow(
            available: available,
            onAdd: (reservoir) => provider.addIngredient(reservoir),
          ),
        ],
      ],
    );
  }
}

// ─── SLIDER INDIVIDUAL ──────────────────────────────────────
class _IngredientSlider extends StatelessWidget {
  final Ingredient ingredient;
  final DrinkPortion portion;
  final DrinkProvider provider;

  const _IngredientSlider({
    required this.ingredient,
    required this.portion,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ((portion.ml / cupMl) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SDColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ingredient.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Color dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: ingredient.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ingredient.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nome
              Expanded(
                child: Text(
                  ingredient.name,
                  style: TextStyle(
                    color: SDColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              // Valores
              Text(
                '${portion.ml}ml',
                style: TextStyle(
                  color: ingredient.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($pct%)',
                style: TextStyle(
                  color: SDColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              // Remover
              GestureDetector(
                onTap: () => provider.removeIngredient(ingredient.reservoir),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SDColors.pink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, color: SDColors.pink, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ingredient.color,
              inactiveTrackColor: ingredient.color.withValues(alpha: 0.15),
              thumbColor: ingredient.color,
              overlayColor: ingredient.color.withValues(alpha: 0.2),
              trackHeight: 10,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: portion.ml.toDouble(),
              min: 0,
              max: cupMl.toDouble(),
              divisions: cupMl ~/ 10,
              onChanged: (val) {
                provider.updatePortionMl(
                  ingredient.reservoir,
                  val.round(),
                );
              },
            ),
          ),
          // Atalhos rápidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [40, 80, 120, 160, 200].map((ml) {
              final isActive = portion.ml == ml;
              return GestureDetector(
                onTap: () => provider.updatePortionMl(ingredient.reservoir, ml),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? ingredient.color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? ingredient.color.withValues(alpha: 0.5)
                          : SDColors.border,
                    ),
                  ),
                  child: Text(
                    '${ml}ml',
                    style: TextStyle(
                      color: isActive ? ingredient.color : SDColors.textMuted,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── ADICIONAR INGREDIENTE ──────────────────────────────────
class _AddIngredientRow extends StatelessWidget {
  final List<Ingredient> available;
  final ValueChanged<int> onAdd;

  const _AddIngredientRow({required this.available, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SDColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SDColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adicionar ingrediente',
            style: TextStyle(
              color: SDColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.map((ing) {
              return GestureDetector(
                onTap: () => onAdd(ing.reservoir),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: ing.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ing.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: ing.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        ing.name,
                        style: TextStyle(
                          color: ing.color,
                          fontSize: 13,
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
      ),
    );
  }
}

// ─── SUMÁRIO DE PORÇÕES ─────────────────────────────────────
class _PortionSummary extends StatelessWidget {
  final List<DrinkPortion> portions;
  const _PortionSummary({required this.portions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: portions.map((p) {
        final ing = defaultIngredients.firstWhere(
          (i) => i.reservoir == p.reservoir,
          orElse: () => defaultIngredients[0],
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ing.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ing.name,
                  style: TextStyle(color: SDColors.textSecondary, fontSize: 12),
                ),
              ),
              Text(
                '${p.ml}ml',
                style: TextStyle(color: SDColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── FOOTER ─────────────────────────────────────────────────
class _CustomizeFooter extends StatelessWidget {
  final DrinkProvider provider;
  const _CustomizeFooter({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Info de tempo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: SDColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SDColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: SDColors.textMuted, size: 18),
              const SizedBox(width: 6),
              Text(
                '${(provider.totalTimeMs / 1000).toStringAsFixed(1)}s',
                style: TextStyle(
                  color: SDColors.cyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Botão fazer
        Expanded(
          child: NeonButton(
            label: 'Fazer drink',
            icon: Icons.local_bar,
            color: SDColors.cyan,
            expanded: true,
            height: 54,
            onPressed: provider.isValid && provider.activeAvailable
                ? () => provider.goToPayment()
                : null,
          ),
        ),
      ],
    );
  }
}
