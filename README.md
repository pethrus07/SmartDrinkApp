[Português](README.pt-BR.md)

# Smart Drink

Kiosk app for an automated drink machine. It runs on the tablet built into the cabinet: the customer picks or builds a drink, pays, and the app tells the valve board how long to open each of the 6 reservoirs.

## Status

Paused (2026-11). Full demo works with the machine and the payment simulated. Waiting for the cabinet design and the choice of the physical link (USB serial, Bluetooth or Wi-Fi). Not published in any store. Built with a partner company that makes the electronics.

| | |
|---|---|
| Platform | Flutter, Android tablet, landscape, kiosk |
| Hardware | 6 reservoirs, valves calibrated at 30 ms per ml plus 100 ms opening, 400 ml cup |

## Run locally

The `android/` folder is already in the repository; no `flutter create` needed.

```bash
flutter pub get
flutter run                              # simulated machine (MockTransport)
flutter run --dart-define=USE_MOCK=false # real machine, once the transport is implemented
```

## Tests

```bash
flutter test
```

19 tests: the `#SD` frame protocol (build and parse), the adjustable calibration, and the admin PIN rules.

## Folders

```
lib/
  main.dart        dependency wiring (transport → service → provider)
  app.dart         MaterialApp and screen routing by state
  core/            pure Dart, no Flutter: calibration, #SD protocol, PIN rules
  hardware/        transport interface, simulator, real transport stub
  services/        machine_service (only class that talks to hardware), drink_provider (UI state)
  data/            local persistence of drinks and settings
  models/          ingredients, portions, presets
  screens/         home, customize, payment, making, done, error, admin
  widgets/, theme/ UI components and visual identity
test/              unit tests
docs/              architecture, protocol, full documentation, roadmap, diagrams
```

Dependency rule: UI → services → hardware/data → core. Screens never build protocol frames or touch the transport, so changing the physical link means implementing one class.

## Architecture

[docs/ARQUITETURA.md](docs/ARQUITETURA.md), diagrams in [docs/arquitetura/](docs/arquitetura/), full functional description in [docs/DOCUMENTACAO.md](docs/DOCUMENTACAO.md) (Portuguese).

## Decisions and known limits

- The machine ships with admin PIN `1234`. The first time someone opens the admin panel, the app requires a new PIN (4 digits, not `1234`, not all equal). Changing it again later from the panel is still on the roadmap.
- Payment (Pix and card) is a visual simulation.
- The firmware does not confirm the end of dispensing, so the app estimates it by time. Open protocol gaps are listed in [docs/PROTOCOLO.md](docs/PROTOCOLO.md).
- `docs/PROTOCOLO.md` describes the partner's firmware protocol. This repository can only be public with the partner's explicit approval.

## Roadmap

[docs/ROADMAP.md](docs/ROADMAP.md)

## License

All rights reserved.
