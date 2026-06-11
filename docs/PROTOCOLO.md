# Protocolo de comunicação Smart Drink

Comunicação em texto entre o app (tablet) e a placa da máquina, em frames delimitados por `#SD;` e `/SD`.

Implementação de referência: `lib/core/sd_protocol.dart` (coberta por `test/sd_protocol_test.dart`).

## Constantes físicas

| Constante | Valor | Descrição |
|---|---|---|
| `msPerMl` | 30 ms | tempo de válvula aberta por ml dispensado |
| `valveOpenMs` | 100 ms | overhead fixo por acionamento de válvula |
| `cupMl` | 400 ml | capacidade do copo |
| `numReservoirs` | 6 | reservatórios (2 de 2 L + 4 de 6 L, conforme protótipo) |

Conversão: `tempo_ms = ml × 30 + 100` (ml > 0); `tempo_ms = 0` quando ml = 0.
Exemplos: 50 ml → 1600 ms · 80 ml → 2500 ms.

## Frames

### 1. Dispensar drink (app → máquina)

```
#SD;1:1600;2:2300;3:2155;4:0;5:0;6:0;/SD
```

- Sempre contém os 6 reservatórios, em ordem, no formato `reservatório:tempo_ms`.
- Tempo `0` = válvula não abre.
- O firmware do protótipo aciona as válvulas **em sequência** (o tempo total do drink é a soma dos tempos).

### 2. Solicitar nível dos reservatórios (app → máquina)

```
#SD;level;/SD
```

### 3. Resposta de nível (máquina → app)

```
#SD;1:2;2:2;3:2;4:2;5:2;6:2;/SD
```

Formato `reservatório:nível`.

> **⚠️ Semântica do nível a confirmar com o firmware:** o protótipo responde `2` para todos. Assumimos a escala `2 = ok / 1 = baixo / 0 = vazio` (3 estados de um sensor de boia). Confirmar e registrar aqui.

## Lacunas conhecidas do protocolo (alinhar com quem faz o firmware)

1. **ACK/conclusão de dispensa** — o protótipo não confirma quando terminou. O app estima por tempo. Proposta: máquina emite `#SD;done;/SD` ao finalizar (o simulador `MockTransport` já se comporta assim).
2. **Relato de erro** — não há frame de erro (válvula travada, reservatório vazio durante a dispensa). Proposta: `#SD;err:<código>;/SD`.
3. **Cancelamento** — não há como abortar uma dispensa em andamento. Proposta: `#SD;stop;/SD`.
4. **Checksum/robustez** — frames sem verificação de integridade; aceitável em cabo curto, revisar se for Bluetooth/WiFi.
5. **Identificação/versão** — para escala comercial, um frame `#SD;info;/SD` retornando versão de firmware e ID da máquina facilita suporte remoto.
