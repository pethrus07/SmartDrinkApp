/// Orquestra a comunicação com a máquina: monta comandos com
/// [SdProtocol], envia pelo [MachineTransport] e acompanha o progresso.
///
/// É a ÚNICA classe que fala com o hardware. UI e providers nunca
/// montam frames nem tocam no transporte diretamente.
library;

import 'dart:async';

import '../core/sd_protocol.dart';
import '../hardware/machine_transport.dart';
import '../models/drink_models.dart';

class MachineService {
  final MachineTransport _transport;
  StreamSubscription<String>? _sub;

  /// Última leitura de nível por reservatório (1..numReservoirs).
  final Map<int, int> levels = {
    for (int i = 1; i <= numReservoirs; i++) i: 2,
  };

  Completer<Map<int, int>>? _pendingLevels;
  Completer<void>? _pendingDone;

  MachineService(this._transport);

  Future<void> init() async {
    await _transport.connect();
    _sub = _transport.frames.listen(_onFrame);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _transport.disconnect();
  }

  bool get isConnected => _transport.isConnected;

  void _onFrame(String frame) {
    final payload = SdProtocol.payloadOf(frame);
    if (payload == null) return;

    if (payload == 'done') {
      _pendingDone?.complete();
      _pendingDone = null;
      return;
    }

    final parsed = SdProtocol.parseLevels(frame);
    if (parsed != null) {
      levels.addAll(parsed);
      _pendingLevels?.complete(Map.of(levels));
      _pendingLevels = null;
    }
  }

  /// Frame de dispensa correspondente às porções (sem enviar).
  /// Usado pela UI para exibir o comando durante o preparo.
  String commandFor(List<DrinkPortion> portions) {
    return SdProtocol.dispenseCommand({
      for (final p in portions)
        if (p.ml > 0) p.reservoir: p.timeMs,
    });
  }

  /// Envia o comando de dispensa e retorna o frame enviado.
  ///
  /// [onProgress] recebe valores 0.0..1.0 estimados pelo tempo total
  /// (o firmware do protótipo não reporta progresso — ver PROTOCOLO.md).
  /// O `Future` completa quando a máquina sinaliza `done` ou, na
  /// ausência de resposta, quando o tempo estimado + margem expira.
  Future<String> dispense(
    List<DrinkPortion> portions, {
    void Function(double progress)? onProgress,
  }) async {
    final times = <int, int>{
      for (final p in portions)
        if (p.ml > 0) p.reservoir: p.timeMs,
    };
    final command = SdProtocol.dispenseCommand(times);
    final totalMs = times.values.fold<int>(0, (s, t) => s + t);

    _pendingDone = Completer<void>();
    final done = _pendingDone!;

    try {
      await _transport.send(command);
    } catch (_) {
      _pendingDone = null;
      rethrow;
    }

    if (totalMs <= 0) {
      _pendingDone = null;
      onProgress?.call(1.0);
      return command;
    }

    // Progresso estimado por tempo.
    const tickMs = 50;
    int elapsed = 0;
    final timer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      elapsed += tickMs;
      onProgress?.call((elapsed / totalMs).clamp(0.0, 1.0));
    });

    try {
      // Aguarda o `done` da máquina com margem de segurança de 3 s.
      await done.future.timeout(Duration(milliseconds: totalMs + 3000));
    } on TimeoutException {
      // Firmware não respondeu — assumimos concluído pelo tempo.
      // TODO(confiabilidade): registrar telemetria/log deste caso.
    } finally {
      timer.cancel();
      _pendingDone = null;
      onProgress?.call(1.0);
    }
    return command;
  }

  /// Solicita os níveis dos reservatórios.
  /// Retorna o mapa atualizado, ou a última leitura conhecida em timeout.
  Future<Map<int, int>> requestLevels() async {
    _pendingLevels = Completer<Map<int, int>>();
    final pending = _pendingLevels!;
    await _transport.send(SdProtocol.levelRequest());
    try {
      return await pending.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      _pendingLevels = null;
      return Map.of(levels);
    }
  }
}
