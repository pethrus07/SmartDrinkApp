import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_models.dart';
import '../services/drink_provider.dart';
import '../theme/sd_theme.dart';
import '../widgets/drink_card.dart';
import '../widgets/cup_widget.dart';
import '../widgets/neon_button.dart';
import '../widgets/drink_thumb.dart';
import '../widgets/pin_dialog.dart';

/// Vitrine do kiosk (tela inicial). Mostra a grade de drinks (presets + criados)
/// e o card "Personalizar"; ao selecionar um drink, um painel lateral exibe a
/// foto/composição e as ações (Ajustar / Fazer drink). Adapta o layout entre
/// paisagem (tablet na máquina) e retrato.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();
    final selected = provider.selectedPreset;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: isLandscape
            ? _LandscapeLayout(provider: provider, selected: selected)
            : _PortraitLayout(provider: provider, selected: selected),
      ),
    );
  }
}

// ─── LANDSCAPE (Tablet em pé = landscape natural) ───────────
class _LandscapeLayout extends StatelessWidget {
  final DrinkProvider provider;
  final DrinkPreset? selected;

  const _LandscapeLayout({required this.provider, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Header ──
          _Header(provider: provider),
          const SizedBox(height: 16),

          // ── Conteúdo principal ──
          Expanded(
            child: Row(
              children: [
                // Grid de drinks (esquerda)
                Expanded(
                  flex: 3,
                  child: _DrinksGrid(
                    provider: provider,
                    selected: selected,
                  ),
                ),
                const SizedBox(width: 20),

                // Painel direito (copo + ações)
                SizedBox(
                  width: 260,
                  child: _SidePanel(
                    provider: provider,
                    selected: selected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PORTRAIT ───────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final DrinkProvider provider;
  final DrinkPreset? selected;

  const _PortraitLayout({required this.provider, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _Header(provider: provider),
          const SizedBox(height: 16),

          // Copo no centro (menor)
          if (selected != null) ...[
            _CompactPreview(selected: selected!, provider: provider),
            const SizedBox(height: 12),
          ],

          // Grid de drinks
          Expanded(
            child: _DrinksGrid(
              provider: provider,
              selected: selected,
            ),
          ),

          const SizedBox(height: 12),

          // Botões
          _BottomActions(provider: provider, selected: selected),
        ],
      ),
    );
  }
}

// ─── HEADER ─────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final DrinkProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: SDColors.glowMix,
          ).createShader(bounds),
          child: Text(
            'SMART',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'DRINK',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: SDColors.orange,
                fontSize: 32,
              ),
        ),
        const Spacer(),
        // Subtítulo
        Text(
          'Escolha seu drink',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SDColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 16),
        // Admin (ícone discreto)
        IconButton(
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => const PinDialog(),
            );
            if (ok == true) provider.goToAdmin();
          },
          icon: const Icon(Icons.settings, color: SDColors.textMuted, size: 20),
          tooltip: 'Configurações',
        ),
      ],
    );
  }
}

// ─── GRID DE DRINKS ─────────────────────────────────────────
class _DrinksGrid extends StatelessWidget {
  final DrinkProvider provider;
  final DrinkPreset? selected;

  const _DrinksGrid({required this.provider, required this.selected});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final crossCount = screenW > 900 ? 4 : (screenW > 600 ? 3 : 2);

    final allDrinks = provider.allDrinks;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: allDrinks.length + 1, // +1 para "Personalizar"
      itemBuilder: (context, index) {
        if (index == allDrinks.length) {
          // Card "Personalizar"
          return _CustomDrinkCard(
            onTap: () => provider.startCustomDrink(),
          );
        }
        final drink = allDrinks[index];
        return DrinkCard(
          drink: drink,
          isSelected: selected?.id == drink.id,
          unavailable: !provider.isDrinkAvailable(drink),
          onTap: () => provider.selectPreset(drink),
        );
      },
    );
  }
}

// ─── CARD "PERSONALIZAR" ────────────────────────────────────
class _CustomDrinkCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CustomDrinkCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SDColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SDColors.purple.withValues(alpha: 0.4),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SDColors.purple.withValues(alpha: 0.15),
                border: Border.all(color: SDColors.purple.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.tune, color: SDColors.purple, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              'Personalizar',
              style: TextStyle(
                color: SDColors.purple,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monte seu drink',
              style: TextStyle(
                color: SDColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PAINEL LATERAL (landscape) ─────────────────────────────
class _SidePanel extends StatelessWidget {
  final DrinkProvider provider;
  final DrinkPreset? selected;

  const _SidePanel({required this.provider, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SDDecorations.glowCard(),
      child: Column(
        children: [
          if (selected != null) ...[
            // Foto do drink (ou copo ilustrado, se não houver imagem)
            DrinkThumb(
              drink: selected!,
              size: 168,
              radius: 24,
              fallback: CupWidget(
                portions: selected!.portions,
                height: 168,
                width: 104,
              ),
            ),
            const SizedBox(height: 14),

            // Nome do drink
            Text(
              selected!.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Miolo rolável (ingredientes + tempo) — botões ficam fixos embaixo.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...selected!.portions.map((p) {
                      final ing = defaultIngredients.firstWhere(
                        (i) => i.reservoir == p.reservoir,
                        orElse: () => defaultIngredients[0],
                      );
                      final pct = ((p.ml / cupMl) * 100).round();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
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
                                  color: SDColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '$pct% · ${p.ml}ml',
                              style: TextStyle(
                                color: SDColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Divider(color: SDColors.border, height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tempo',
                            style: TextStyle(
                                color: SDColors.textMuted, fontSize: 12)),
                        Text(
                          '${(selected!.totalTimeMs / 1000).toStringAsFixed(1)}s',
                          style: TextStyle(
                            color: SDColors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão personalizar
            NeonButton(
              label: 'Ajustar',
              icon: Icons.tune,
              color: SDColors.purple,
              expanded: true,
              height: 48,
              onPressed: () => provider.goToCustomizeFromPreset(),
            ),
            const SizedBox(height: 10),

            // Botão fazer drink
            if (!provider.activeAvailable) ...[
              Text(
                'Ingrediente em falta — procure o atendente',
                textAlign: TextAlign.center,
                style: TextStyle(color: SDColors.pink, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],
            NeonButton(
              label: 'Fazer drink',
              icon: Icons.local_bar,
              color: SDColors.cyan,
              expanded: true,
              height: 56,
              onPressed:
                  provider.activeAvailable ? () => provider.goToPayment() : null,
            ),
          ] else ...[
            const Spacer(),
            Icon(Icons.touch_app, color: SDColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              'Selecione um drink\nou personalize o seu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SDColors.textMuted,
                fontSize: 14,
              ),
            ),
            const Spacer(),
          ],
        ],
      ),
    );
  }
}

// ─── PREVIEW COMPACTO (portrait) ────────────────────────────
class _CompactPreview extends StatelessWidget {
  final DrinkPreset selected;
  final DrinkProvider provider;

  const _CompactPreview({required this.selected, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: SDDecorations.glowCard(),
      child: Row(
        children: [
          DrinkThumb(
            drink: selected,
            size: 80,
            radius: 16,
            fallback: CupWidget(
              portions: selected.portions,
              height: 80,
              width: 50,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  selected.description,
                  style: TextStyle(color: SDColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${(selected.totalTimeMs / 1000).toStringAsFixed(1)}s',
            style: TextStyle(
              color: SDColors.cyan,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BOTÕES INFERIORES (portrait) ───────────────────────────
class _BottomActions extends StatelessWidget {
  final DrinkProvider provider;
  final DrinkPreset? selected;

  const _BottomActions({required this.provider, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (selected != null) ...[
          Expanded(
            child: NeonButton(
              label: 'Ajustar',
              icon: Icons.tune,
              color: SDColors.purple,
              expanded: true,
              height: 52,
              onPressed: () => provider.goToCustomizeFromPreset(),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: selected != null ? 2 : 1,
          child: NeonButton(
            label: 'Fazer drink',
            icon: Icons.local_bar,
            color: SDColors.cyan,
            expanded: true,
            height: 52,
            onPressed: selected != null && provider.activeAvailable
                ? () => provider.goToPayment()
                : null,
          ),
        ),
      ],
    );
  }
}
