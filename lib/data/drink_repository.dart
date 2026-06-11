/// Persistência local dos drinks criados pelo owner.
///
/// Hoje usa SharedPreferences (JSON serializado) — suficiente para o
/// volume de dados de uma máquina. Se o catálogo crescer ou ganhar
/// sincronização remota, trocar a implementação aqui sem afetar o resto.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/drink_models.dart';

class DrinkRepository {
  static const _key = 'user_drinks_v1';

  Future<List<DrinkPreset>> loadUserDrinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => DrinkPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Dados corrompidos não podem derrubar o kiosk: começa vazio.
      return [];
    }
  }

  Future<void> saveUserDrinks(List<DrinkPreset> drinks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(drinks.map((d) => d.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
