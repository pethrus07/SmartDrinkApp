/// Transporte físico real — AINDA NÃO IMPLEMENTADO.
///
/// DECISÃO PENDENTE (registrar no ROADMAP): qual o canal físico entre o
/// tablet e a placa da máquina?
///
/// Opções avaliadas:
///
/// 1. **USB Serial (OTG)** — pacote `usb_serial` ou `flutter_libserialport`.
///    Mais confiável para kiosk (sem pareamento, sem queda de sinal),
///    alimenta dados e energia pelo mesmo cabo dependendo do tablet.
///    Recomendado se o tablet ficar fixo dentro do gabinete.
///
/// 2. **Bluetooth Classic/BLE** — pacote `flutter_blue_plus`.
///    Sem cabo, porém pareamento e reconexão são pontos de falha em
///    operação comercial autônoma.
///
/// 3. **WiFi/TCP (ESP32 como AP)** — `dart:io` Socket puro.
///    Flexível e permite atualização OTA do firmware, mas adiciona
///    stack de rede a manter.
///
/// Quando o canal for decidido:
///   - adicionar a dependência no pubspec.yaml;
///   - implementar esta classe respeitando [MachineTransport];
///   - bufferizar bytes recebidos até formar frames `#SD;...;/SD`
///     completos antes de emitir em [frames];
///   - trocar a injeção em `main.dart` (flag `kUseMockTransport`).
///
/// Nenhuma outra parte do app precisa mudar.
library;

import 'dart:async';

import 'machine_transport.dart';

class UsbSerialTransport implements MachineTransport {
  @override
  Future<void> connect() {
    throw UnimplementedError(
      'Canal físico ainda não definido — ver docs/ROADMAP.md',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  bool get isConnected => false;

  @override
  Future<void> send(String frame) {
    throw UnimplementedError();
  }

  @override
  Stream<String> get frames => const Stream.empty();
}
