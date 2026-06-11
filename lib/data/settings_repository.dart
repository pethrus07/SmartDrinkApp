/// Configurações da máquina + estatísticas de uso, persistidas localmente.
///
/// Tudo que o owner ajusta no painel admin (calibragem, preço, nomes
/// dos reservatórios, PIN) e os contadores de operação vivem aqui.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/machine_config.dart';

class AppSettings {
  int msPerMl;
  int valveOpenMs;

  /// Preço por drink em centavos (evita erro de ponto flutuante).
  int drinkPriceCents;

  /// PIN de acesso ao painel admin.
  String adminPin;

  /// Nome configurado por reservatório (sobrepõe o padrão).
  Map<int, String> ingredientNames;

  /// Estatísticas de operação.
  int drinksServed;
  Map<int, int> mlServedByReservoir;

  AppSettings({
    required this.msPerMl,
    required this.valveOpenMs,
    required this.drinkPriceCents,
    required this.adminPin,
    required this.ingredientNames,
    required this.drinksServed,
    required this.mlServedByReservoir,
  });

  factory AppSettings.defaults() => AppSettings(
        msPerMl: defaultMsPerMl,
        valveOpenMs: defaultValveOpenMs,
        drinkPriceCents: 1500, // R$ 15,00
        adminPin: '1234',
        ingredientNames: {},
        drinksServed: 0,
        mlServedByReservoir: {
          for (int i = 1; i <= numReservoirs; i++) i: 0,
        },
      );

  Map<String, dynamic> toJson() => {
        'msPerMl': msPerMl,
        'valveOpenMs': valveOpenMs,
        'drinkPriceCents': drinkPriceCents,
        'adminPin': adminPin,
        'ingredientNames':
            ingredientNames.map((k, v) => MapEntry(k.toString(), v)),
        'drinksServed': drinksServed,
        'mlServedByReservoir':
            mlServedByReservoir.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final d = AppSettings.defaults();
    return AppSettings(
      msPerMl: json['msPerMl'] as int? ?? d.msPerMl,
      valveOpenMs: json['valveOpenMs'] as int? ?? d.valveOpenMs,
      drinkPriceCents: json['drinkPriceCents'] as int? ?? d.drinkPriceCents,
      adminPin: json['adminPin'] as String? ?? d.adminPin,
      ingredientNames: (json['ingredientNames'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(int.parse(k), v as String)),
      drinksServed: json['drinksServed'] as int? ?? 0,
      mlServedByReservoir:
          (json['mlServedByReservoir'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(int.parse(k), v as int))
            ..addEntries([
              for (int i = 1; i <= numReservoirs; i++)
                if (!(json['mlServedByReservoir'] as Map<String, dynamic>? ??
                        {})
                    .containsKey('$i'))
                  MapEntry(i, 0),
            ]),
    );
  }
}

class SettingsRepository {
  static const _key = 'app_settings_v1';

  Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return AppSettings.defaults();
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Configuração corrompida não pode derrubar o kiosk.
      return AppSettings.defaults();
    }
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
