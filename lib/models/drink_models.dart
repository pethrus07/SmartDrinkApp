import 'package:flutter/material.dart';

import '../core/machine_config.dart';

// Re-exporta as constantes da máquina: as telas que importam
// drink_models continuam enxergando cupMl, msPerMl, etc.
export '../core/machine_config.dart';

// ─── INGREDIENTE (ligado a um reservatório) ─────────────────
class Ingredient {
  final int reservoir; // 1..numReservoirs
  final String name;
  final Color color;
  final IconData icon;

  const Ingredient({
    required this.reservoir,
    required this.name,
    required this.color,
    required this.icon,
  });
}

// ─── PORÇÃO DENTRO DE UMA RECEITA ───────────────────────────
class DrinkPortion {
  final int reservoir;
  final int ml;

  const DrinkPortion({required this.reservoir, required this.ml});

  int get percent => cupMl > 0 ? ((ml / cupMl) * 100).round() : 0;
  int get timeMs => mlToTimeMs(ml);

  DrinkPortion copyWith({int? ml}) =>
      DrinkPortion(reservoir: reservoir, ml: ml ?? this.ml);

  Map<String, dynamic> toJson() => {'reservoir': reservoir, 'ml': ml};

  factory DrinkPortion.fromJson(Map<String, dynamic> json) => DrinkPortion(
        reservoir: json['reservoir'] as int,
        ml: json['ml'] as int,
      );
}

// ─── DRINK (preset de fábrica ou criado pelo owner) ─────────
class DrinkPreset {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<DrinkPortion> portions;

  const DrinkPreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.portions,
  });

  int get totalMl => portions.fold(0, (sum, p) => sum + p.ml);
  int get totalTimeMs => portions.fold(0, (sum, p) => sum + p.timeMs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'description': description,
        'portions': portions.map((p) => p.toJson()).toList(),
      };

  factory DrinkPreset.fromJson(Map<String, dynamic> json) => DrinkPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '🍸',
        description: json['description'] as String? ?? '',
        portions: (json['portions'] as List)
            .map((p) => DrinkPortion.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

// ─── INGREDIENTES PADRÃO (6 reservatórios) ──────────────────
// TODO(escala): tornar configurável pelo painel admin e persistir
// por máquina — cada cliente carrega bebidas diferentes.
final List<Ingredient> defaultIngredients = [
  const Ingredient(
    reservoir: 1,
    name: 'Vodka',
    color: Color(0xFF90CAF9),
    icon: Icons.local_bar,
  ),
  const Ingredient(
    reservoir: 2,
    name: 'Gin',
    color: Color(0xFFA5D6A7),
    icon: Icons.local_bar,
  ),
  const Ingredient(
    reservoir: 3,
    name: 'Rum',
    color: Color(0xFFFFCC80),
    icon: Icons.local_bar,
  ),
  const Ingredient(
    reservoir: 4,
    name: 'Energético',
    color: Color(0xFF80DEEA),
    icon: Icons.flash_on,
  ),
  const Ingredient(
    reservoir: 5,
    name: 'Suco de Limão',
    color: Color(0xFFFFF59D),
    icon: Icons.emoji_nature,
  ),
  const Ingredient(
    reservoir: 6,
    name: 'Tônica',
    color: Color(0xFFCE93D8),
    icon: Icons.bubble_chart,
  ),
];

// ─── DRINKS PRESET DE FÁBRICA ───────────────────────────────
final List<DrinkPreset> presetDrinks = [
  const DrinkPreset(
    id: 'tropical',
    name: 'Tropical Fizz',
    emoji: '🍹',
    description: 'Energético + Vodka + Limão',
    portions: [
      DrinkPortion(reservoir: 4, ml: 200),
      DrinkPortion(reservoir: 1, ml: 80),
      DrinkPortion(reservoir: 5, ml: 120),
    ],
  ),
  const DrinkPreset(
    id: 'gin_tonica',
    name: 'Gin Tônica',
    emoji: '🫧',
    description: 'Gin + Tônica + Limão',
    portions: [
      DrinkPortion(reservoir: 2, ml: 120),
      DrinkPortion(reservoir: 6, ml: 240),
      DrinkPortion(reservoir: 5, ml: 40),
    ],
  ),
  const DrinkPreset(
    id: 'vodka_energy',
    name: 'Vodka Energy',
    emoji: '⚡',
    description: 'Vodka + Energético',
    portions: [
      DrinkPortion(reservoir: 1, ml: 120),
      DrinkPortion(reservoir: 4, ml: 280),
    ],
  ),
  const DrinkPreset(
    id: 'rum_cola',
    name: 'Rum Tropical',
    emoji: '🏝️',
    description: 'Rum + Energético + Limão',
    portions: [
      DrinkPortion(reservoir: 3, ml: 120),
      DrinkPortion(reservoir: 4, ml: 200),
      DrinkPortion(reservoir: 5, ml: 80),
    ],
  ),
  const DrinkPreset(
    id: 'estrela',
    name: 'Estrela Cadente',
    emoji: '⭐',
    description: 'Vodka + Gin + Energético',
    portions: [
      DrinkPortion(reservoir: 1, ml: 80),
      DrinkPortion(reservoir: 2, ml: 80),
      DrinkPortion(reservoir: 4, ml: 240),
    ],
  ),
  const DrinkPreset(
    id: 'limao_fizz',
    name: 'Limão Fizz',
    emoji: '🍋',
    description: 'Gin + Limão + Tônica',
    portions: [
      DrinkPortion(reservoir: 2, ml: 80),
      DrinkPortion(reservoir: 5, ml: 120),
      DrinkPortion(reservoir: 6, ml: 200),
    ],
  ),
  const DrinkPreset(
    id: 'purple_rain',
    name: 'Purple Rain',
    emoji: '🌧️',
    description: 'Vodka + Gin + Tônica',
    portions: [
      DrinkPortion(reservoir: 1, ml: 80),
      DrinkPortion(reservoir: 2, ml: 80),
      DrinkPortion(reservoir: 6, ml: 240),
    ],
  ),
  const DrinkPreset(
    id: 'sunrise',
    name: 'Sunrise',
    emoji: '🌅',
    description: 'Rum + Vodka + Limão + Energético',
    portions: [
      DrinkPortion(reservoir: 3, ml: 80),
      DrinkPortion(reservoir: 1, ml: 80),
      DrinkPortion(reservoir: 5, ml: 80),
      DrinkPortion(reservoir: 4, ml: 160),
    ],
  ),
];
