/// Canal de comunicação entre o app (tablet) e a eletrônica da máquina.
///
/// O app NÃO conhece o meio físico (USB serial, Bluetooth, WiFi/ESP32).
/// Toda comunicação passa por esta interface, o que permite:
///   - desenvolver e demonstrar o app sem a máquina ([MockTransport]);
///   - trocar o canal físico sem tocar em UI ou regras de negócio;
///   - testar serviços com um transporte falso.
library;

abstract class MachineTransport {
  /// Abre a conexão com a máquina. Idempotente.
  Future<void> connect();

  /// Encerra a conexão. Idempotente.
  Future<void> disconnect();

  bool get isConnected;

  /// Envia um frame de comando (ex.: `#SD;1:1600;...;/SD`).
  /// Lança [TransportException] se não for possível enviar.
  Future<void> send(String frame);

  /// Stream de frames recebidos da máquina, já remontados linha a linha
  /// (a implementação é responsável por bufferizar bytes até formar
  /// um frame completo `#SD;...;/SD`).
  Stream<String> get frames;
}

class TransportException implements Exception {
  final String message;
  TransportException(this.message);

  @override
  String toString() => 'TransportException: $message';
}
