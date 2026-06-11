/// Simulador da eletrônica da máquina.
///
/// Permite rodar o app completo (incluindo a tela "preparando drink")
/// sem a máquina física. Comporta-se como o firmware:
///   - ao receber um comando de dispensa, "abre as válvulas" pelo tempo
///     pedido e emite `#SD;done;/SD` ao terminar;
///   - ao receber `#SD;level;/SD`, responde com os níveis atuais;
///   - decrementa os níveis simulados conforme drinks são servidos.
library;

import 'dart:async';

import '../core/machine_config.dart';
import '../core/sd_protocol.dart';
import 'machine_transport.dart';

class MockTransport implements MachineTransport {
  bool _connected = false;
  final _controller = StreamController<String>.broadcast();

  /// Nível simulado por reservatório. Semântica do protótipo:
  /// 2 = cheio, 1 = baixo, 0 = vazio (ver docs/PROTOCOLO.md).
  final Map<int, int> _levels = {
    for (int i = 1; i <= numReservoirs; i++) i: 2,
  };

  /// Acelera a simulação (1.0 = tempo real). Útil em demos.
  final double timeScale;

  MockTransport({this.timeScale = 1.0});

  @override
  Future<void> connect() async {
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  bool get isConnected => _connected;

  @override
  Stream<String> get frames => _controller.stream;

  @override
  Future<void> send(String frame) async {
    if (!_connected) {
      throw TransportException('Mock não conectado');
    }

    final payload = SdProtocol.payloadOf(frame);
    if (payload == null) return; // frame inválido: firmware ignora

    if (payload == SdProtocol.levelKeyword) {
      _emitLevels();
      return;
    }

    // Comando de dispensa: simula o tempo da válvula mais longa
    // (no protótipo as válvulas abrem em sequência; somamos os tempos).
    final times = SdProtocol.parseLevels(frame); // mesmo formato par k:v
    if (times == null) return;

    final totalMs = times.values.fold<int>(0, (s, t) => s + t);
    if (totalMs > 0) {
      // Consome estoque simulado dos reservatórios usados.
      for (final entry in times.entries) {
        if (entry.value > 0 && (_levels[entry.key] ?? 0) > 0) {
          _levels[entry.key] = (_levels[entry.key]! - 1).clamp(0, 2);
        }
      }
      await Future.delayed(
        Duration(milliseconds: (totalMs / timeScale).round()),
      );
      if (_connected) _controller.add('#SD;done;/SD');
    }
  }

  void _emitLevels() {
    final parts = [
      for (int i = 1; i <= numReservoirs; i++) '$i:${_levels[i]}',
    ];
    _controller.add('${SdProtocol.framePrefix}${parts.join(';')};'
        '${SdProtocol.frameSuffix}');
  }

  void dispose() {
    _controller.close();
  }
}
