[English](README.md)

# Smart Drink

App kiosk de uma máquina automática de drinks. Roda no tablet embutido no gabinete: o cliente escolhe ou monta um drink, paga, e o app diz à placa das válvulas quanto tempo abrir cada um dos 6 reservatórios.

## Status

Pausado (11/2026). A demo completa funciona com a máquina e o pagamento simulados. Esperando o projeto do gabinete e a escolha do canal físico (USB serial, Bluetooth ou Wi-Fi). Não publicado em loja. Feito com uma empresa parceira que faz a eletrônica.

| | |
|---|---|
| Plataforma | Flutter, tablet Android, paisagem, kiosk |
| Hardware | 6 reservatórios, válvulas calibradas em 30 ms por ml mais 100 ms de abertura, copo de 400 ml |

## Rodar localmente

A pasta `android/` já está no repositório; não precisa de `flutter create`.

```bash
flutter pub get
flutter run                              # máquina simulada (MockTransport)
flutter run --dart-define=USE_MOCK=false # máquina real, quando o transporte existir
```

## Testes

```bash
flutter test
```

19 testes: o protocolo de frames `#SD` (montagem e leitura), a calibragem ajustável e as regras do PIN do admin.

## Pastas

```
lib/
  main.dart        composição de dependências (transporte → serviço → provider)
  app.dart         MaterialApp e roteamento de telas por estado
  core/            Dart puro, sem Flutter: calibragem, protocolo #SD, regras do PIN
  hardware/        interface do transporte, simulador, esqueleto do transporte real
  services/        machine_service (única classe que fala com o hardware), drink_provider (estado da UI)
  data/            persistência local dos drinks e das configurações
  models/          ingredientes, porções, presets
  screens/         home, customize, pagamento, preparo, pronto, erro, admin
  widgets/, theme/ componentes e identidade visual
test/              testes de unidade
docs/              arquitetura, protocolo, documentação completa, roadmap, diagramas
```

Regra de dependência: UI → services → hardware/data → core. As telas nunca montam frame do protocolo nem tocam no transporte; trocar o canal físico é implementar uma classe.

## Arquitetura

[docs/ARQUITETURA.md](docs/ARQUITETURA.md), diagramas em [docs/arquitetura/](docs/arquitetura/), descrição funcional completa em [docs/DOCUMENTACAO.md](docs/DOCUMENTACAO.md).

## Decisões e limites conhecidos

- A máquina sai de fábrica com o PIN de admin `1234`. Na primeira vez que alguém abre o painel admin, o app exige um PIN novo (4 dígitos, diferente de `1234`, sem todos iguais). Trocar de novo depois pelo painel ainda está no roadmap.
- O pagamento (Pix e cartão) é uma simulação visual.
- O firmware não confirma o fim da dispensa, então o app estima pelo tempo. As lacunas do protocolo estão em [docs/PROTOCOLO.md](docs/PROTOCOLO.md).
- `docs/PROTOCOLO.md` descreve o protocolo do firmware do parceiro. Este repositório só pode ficar público com o OK explícito dele.

## Roadmap

[docs/ROADMAP.md](docs/ROADMAP.md)

## Licença

Todos os direitos reservados.
