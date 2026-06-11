# Arquitetura

## Princípio

O app é um **kiosk de controle de hardware**. As duas coisas que mais vão mudar com o tempo são (a) o canal físico de comunicação e (b) o catálogo/configuração por máquina. A arquitetura isola exatamente esses dois pontos.

```
┌─────────────────────────────────────────────┐
│  screens/ + widgets/        (Flutter UI)    │
│        │ watch/read                         │
│  services/drink_provider    (estado da UI)  │
│        │                                    │
│  services/machine_service   (orquestração)  │   data/drink_repository
│        │                                    │   (persistência local)
│  hardware/machine_transport (interface)     │
│   ├─ mock_transport         (simulador)     │
│   └─ usb_serial_transport   (real, pendente)│
│        │                                    │
│  core/sd_protocol + machine_config          │
│  (Dart puro — unit-testável sem Flutter)    │
└─────────────────────────────────────────────┘
```

## Decisões e justificativas

**Navegação por enum + `AnimatedSwitcher`, sem `Navigator`.**
Kiosk não tem botão voltar do sistema, deep link nem rotas externas. Um ciclo fechado de 5 telas controlado por estado é mais simples de raciocinar e impossível de "escapar". Se o app ganhar fluxos paralelos no futuro, migrar para `go_router`.

**`provider` como gerência de estado.**
Já estava em uso, é suficiente para o escopo e tem manutenção garantida. Não há justificativa para bloc/riverpod neste tamanho de app; reavaliar apenas se o estado crescer em complexidade real.

**Protocolo em `core/` como Dart puro.**
O frame `#SD` é o contrato com o firmware — o lugar com maior custo de bug (drink errado servido a cliente). Por isso é a parte mais testada do projeto e não depende de Flutter, podendo ser reaproveitada numa CLI de bancada para testar a placa sem o tablet.

**`MachineTransport` como interface.**
A decisão USB vs Bluetooth vs WiFi ainda não foi tomada (ver ROADMAP). O custo de errar essa aposta cai a quase zero: implementar uma classe nova e trocar uma linha no `main.dart`. O `MockTransport` também permite desenvolver/demonstrar o app inteiro sem a máquina.

**`MachineService` como único ponto de contato com o hardware.**
Concentra timeout, progresso estimado, leitura de níveis e (futuramente) fila/lock de comandos — uma dispensa por vez, nunca duas em paralelo.

**Persistência via repositório.**
Drinks do owner hoje vivem em `SharedPreferences` (JSON). A interface do repositório permite trocar por SQLite ou sync remoto sem tocar no provider.

## Convenções

- Telas não importam nada de `hardware/` nem `core/sd_protocol.dart`.
- Constantes físicas só em `core/machine_config.dart`.
- Todo frame novo do protocolo entra com teste em `test/sd_protocol_test.dart` e atualização do `docs/PROTOCOLO.md`.
- Comentários e nomes de domínio em pt-BR; identificadores de código em inglês quando natural do Flutter.
