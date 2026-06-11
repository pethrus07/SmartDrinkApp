import 'package:flutter/material.dart';
import '../models/drink_models.dart';
import '../theme/sd_theme.dart';
import 'drink_illustration.dart';

class DrinkCard extends StatelessWidget {
  final DrinkPreset drink;
  final bool isSelected;
  final bool unavailable;
  final VoidCallback onTap;

  const DrinkCard({
    super.key,
    required this.drink,
    required this.isSelected,
    this.unavailable = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: unavailable ? 0.45 : 1.0,
        child: Stack(
          children: [
            _buildCard(context),
            if (unavailable)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SDColors.pink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: SDColors.pink.withOpacity(0.6)),
                  ),
                  child: Text(
                    'EM FALTA',
                    style: TextStyle(
                      color: SDColors.pink,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: isSelected
            ? SDDecorations.neonBorder(color: SDColors.cyan)
                .copyWith(color: SDColors.card)
            : SDDecorations.glowCard(glowColor: SDColors.purple.withOpacity(0.3))
                ,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ilustração do drink + nome
            Row(
              children: [
                DrinkIllustration(
                  portions: drink.portions,
                  size: 48,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    drink.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? SDColors.cyan
                              : SDColors.textPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descrição
            Text(
              drink.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SDColors.textMuted,
                    fontSize: 12,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Barras de ingredientes
            _IngredientBars(portions: drink.portions),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${drink.totalMl}ml',
                  style: TextStyle(
                    color: SDColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(drink.totalTimeMs / 1000).toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: SDColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _IngredientBars extends StatelessWidget {
  final List<DrinkPortion> portions;

  const _IngredientBars({required this.portions});

  @override
  Widget build(BuildContext context) {
    final totalMl = portions.fold(0, (s, p) => s + p.ml);
    if (totalMl == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: portions.map((p) {
            final ing = defaultIngredients.firstWhere(
              (i) => i.reservoir == p.reservoir,
              orElse: () => defaultIngredients[0],
            );
            final fraction = p.ml / totalMl;
            return Expanded(
              flex: (fraction * 100).round().clamp(1, 100),
              child: Container(color: ing.color.withOpacity(0.8)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
