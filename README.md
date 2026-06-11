# Smart Drink 🍹

App de controle (modo kiosk) da máquina de drinks **Smart Drink** — roda no tablet embutido no gabinete e comanda a eletrônica das válvulas.

| | |
|---|---|
| **Plataforma** | Flutter (Android tablet, landscape, kiosk) |
| **Estado** | Protótipo funcional com máquina simulada |
| **Hardware** | 6 reservatórios, válvulas com calibragem 30 ms/ml + 100 ms de abertura, copo de 400 ml |

## Como rodar

```bash
flutter create . --platforms=android   # 1ª vez: gera a pasta android/
flutter pub get
flutter run                            # roda com a máquina SIMULADA
```

Para rodar contra a máquina real (quando o transporte físico for implementado):

```bash
flutter run --dart-define=USE_MOCK=false
```

Testes:

```bash
flutter test
```

## Arquitetura (resumo)

```
lib/
├── main.dart          # composição de dependências (transporte → serviço → provider)
├── app.dart           # MaterialApp + roteador de telas por estado
├── core/              # Dart puro, testável, sem Flutter
│   ├── machine_config.dart   # calibragem e constantes físicas
│   └── sd_protocol.dart      # frames #SD;...;/SD (montagem e parse)
├── hardware/          # canal físico de comunicação
│   ├── machine_transport.dart    # interface (contrato)
│   ├── mock_transport.dart       # simulador da máquina (dev/demo)
│   └── usb_serial_transport.dart # stub do transporte real (pendente)
├── services/
│   ├── machine_service.dart  # única classe que fala com o hardware
│   └── drink_provider.dart   # estado da UI (navegação, drink, progresso)
├── data/
│   └── drink_repository.dart # persistência dos drinks do owner
├── models/            # Ingredient, DrinkPortion, DrinkPreset (+ JSON)
├── screens/           # home, customize, create, making, done, admin
├── theme/             # identidade visual neon
└── widgets/           # componentes reutilizáveis
```

Regra de dependência: **UI → services → hardware/data → core**. Telas nunca montam frames de protocolo nem tocam no transporte; trocar o canal físico (USB/Bluetooth/WiFi) exige implementar uma única classe.

Detalhes em [docs/ARQUITETURA.md](docs/ARQUITETURA.md) · Protocolo em [docs/PROTOCOLO.md](docs/PROTOCOLO.md) · Pendências em [docs/ROADMAP.md](docs/ROADMAP.md).

## Fluxo do usuário

1. **Home** — grade de drinks (presets de fábrica + criados pelo owner) ou modo personalizar
2. **Customize** — ajuste de porções por reservatório, limitado ao copo de 400 ml
3. **Making** — comando enviado à máquina, progresso estimado por tempo
4. **Done** — confirmação e retorno ao início
5. **Admin** — gerenciar drinks, níveis dos reservatórios, calibragem e teste de válvulas
