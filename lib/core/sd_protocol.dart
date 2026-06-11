/// Protocolo de comunicação Smart Drink (frames `#SD;...;/SD`).
///
/// Módulo Dart puro — sem dependência de Flutter — para que o protocolo
/// possa ser testado por unit tests e reutilizado em outras ferramentas
/// (CLI de bancada, firmware-simulator, etc.).
///
/// Frames definidos (ver docs/PROTOCOLO.md):
///
/// 1. Dispensar drink (app → máquina):
///    `#SD;1:1600;2:2300;3:2155;4:0;5:0;6:0;/SD`
///    Cada par `reservatório:tempo_ms`. Tempo 0 = válvula não abre.
///
/// 2. Solicitar nível dos reservatórios (app → máquina):
///    `#SD;level;/SD`
///
/// 3. Resposta de nível (máquina → app):
///    `#SD;1:2;2:2;3:2;4:2;5:2;6:2;/SD`
///    Cada par `reservatório:nível`.
library;

import 'machine_config.dart';

class SdProtocol {
  SdProtocol._();

  static const String framePrefix = '#SD;';
  static const String frameSuffix = '/SD';
  static const String levelKeyword = 'level';

  /// Monta o comando de dispensa a partir de um mapa
  /// `reservatório (1..numReservoirs) -> tempo em ms`.
  ///
  /// Reservatórios ausentes no mapa são enviados com tempo 0,
  /// garantindo que o frame sempre contenha os 6 reservatórios
  /// na ordem — o firmware do protótipo espera o frame completo.
  static String dispenseCommand(Map<int, int> reservoirTimesMs) {
    final parts = <String>[];
    for (int i = 1; i <= numReservoirs; i++) {
      final t = reservoirTimesMs[i] ?? 0;
      assert(t >= 0, 'Tempo negativo para reservatório $i');
      parts.add('$i:${t < 0 ? 0 : t}');
    }
    return '$framePrefix${parts.join(';')};$frameSuffix';
  }

  /// Comando de solicitação de nível dos reservatórios.
  static String levelRequest() => '$framePrefix$levelKeyword;$frameSuffix';

  /// Verifica se a string é um frame completo do protocolo.
  static bool isFrame(String raw) {
    final s = raw.trim();
    return s.startsWith(framePrefix) && s.endsWith(frameSuffix);
  }

  /// Extrai o payload (conteúdo entre `#SD;` e `;/SD` ou `/SD`).
  static String? payloadOf(String raw) {
    final s = raw.trim();
    if (!isFrame(s)) return null;
    var body = s.substring(framePrefix.length, s.length - frameSuffix.length);
    if (body.endsWith(';')) body = body.substring(0, body.length - 1);
    return body;
  }

  /// Tenta interpretar um frame como resposta de nível.
  /// Retorna `reservatório -> nível` ou `null` se o frame não for
  /// uma resposta de nível válida.
  static Map<int, int>? parseLevels(String raw) {
    final body = payloadOf(raw);
    if (body == null || body.isEmpty || body == levelKeyword) return null;

    final result = <int, int>{};
    for (final pair in body.split(';')) {
      final kv = pair.split(':');
      if (kv.length != 2) return null;
      final reservoir = int.tryParse(kv[0]);
      final level = int.tryParse(kv[1]);
      if (reservoir == null || level == null) return null;
      if (reservoir < 1 || reservoir > numReservoirs) return null;
      result[reservoir] = level;
    }
    return result.isEmpty ? null : result;
  }
}
