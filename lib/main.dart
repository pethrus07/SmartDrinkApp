import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/drink_repository.dart';
import 'hardware/machine_transport.dart';
import 'hardware/mock_transport.dart';
import 'services/drink_provider.dart';
import 'services/machine_service.dart';

/// Troque para `false` quando o transporte físico estiver implementado
/// (ver lib/hardware/usb_serial_transport.dart e docs/ROADMAP.md).
/// Também pode ser controlado por build:
///   flutter run --dart-define=USE_MOCK=false
const bool kUseMockTransport =
    bool.fromEnvironment('USE_MOCK', defaultValue: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tablet fixo da máquina: landscape + modo kiosk.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ── Composição de dependências ──
  final MachineTransport transport = kUseMockTransport
      ? MockTransport()
      // ignore: dead_code
      : throw UnimplementedError('Transporte físico pendente — ROADMAP.md');

  final machine = MachineService(transport);
  await machine.init();

  final provider = DrinkProvider(
    machine: machine,
    repository: DrinkRepository(),
  );
  // Carrega drinks salvos e níveis sem bloquear o primeiro frame.
  provider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const SmartDrinkApp(),
    ),
  );
}
