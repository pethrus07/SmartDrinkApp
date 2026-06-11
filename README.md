# Smart Drink 🍹

App de controle (modo kiosk) da máquina de drinks **Smart Drink** — roda no tablet embutido no gabinete e comanda a eletrônica das válvulas.

| | |
|---|---|
| **Plataforma** | Flutter (Android tablet, landscape, kiosk) |
| **Estado** | Demo funcional completa — máquina e pagamento simulados |
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

1. **Home** — grade de drinks (presets + criados pelo owner); drinks com ingrediente em falta aparecem com selo "EM FALTA" e não podem ser pedidos
2. **Customize** — ajuste de porções por reservatório, limitado ao copo de 400 ml; reservatórios vazios não podem ser adicionados
3. **Pagamento** *(simulado)* — Pix (QR ilustrativo) ou cartão, aprovação automática ou pelo botão de demo
4. **Making** — comando enviado à máquina, progresso estimado por tempo
5. **Done** — confirmação e retorno ao início · **Error** — falha no preparo ("procure o atendente")
6. **Admin** *(PIN padrão: 1234)* — gerenciar drinks, reservatórios (nível, renomear, reabastecer), estatísticas de uso, preço do drink, simulação de falha, calibragem editável e teste de válvulas

> Tudo funciona sem hardware: o `MockTransport` simula a máquina (níveis, consumo de estoque, conclusão do preparo) e o pagamento é uma simulação visual do fluxo previsto.
