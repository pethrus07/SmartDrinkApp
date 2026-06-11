# Roadmap

## 🔴 Decisões pendentes (bloqueiam a próxima fase)

1. **Canal físico tablet ↔ placa** — USB serial (OTG), Bluetooth ou WiFi/ESP32?
   Recomendação inicial: **USB serial**, por confiabilidade em operação autônoma (sem pareamento, sem queda de sinal, tablet fixo no gabinete). Implementar em `lib/hardware/usb_serial_transport.dart`.
2. **Firmware: protocolo de resposta** — alinhar `done`, erro e cancelamento (ver lacunas em PROTOCOLO.md). Sem `done`, o app só pode estimar o término por tempo.
3. **Semântica do nível dos reservatórios** — confirmar a escala (0/1/2?) com o firmware.
4. **Válvulas em sequência ou paralelo?** — afeta o tempo total exibido ao cliente. Hoje assumimos sequência (soma dos tempos).

## v0.3 — Conectar à máquina real

- [ ] Implementar o transporte escolhido (+ reconexão automática)
- [ ] Tela/banner de "máquina desconectada" (hoje falha silenciosa)
- [ ] Bloquear drinks cujo reservatório está vazio (nível 0)
- [ ] Tela de erro de dispensa ("procure o atendente")
- [ ] Logs persistentes de comandos enviados (auditoria/suporte)

## v0.4 — Operação comercial

- [ ] PIN no acesso ao painel admin (hoje aberto a qualquer toque)
- [ ] Ingredientes configuráveis por máquina (nome/cor do reservatório) com persistência
- [ ] Calibragem ajustável pelo admin (ms/ml por válvula, persistida)
- [ ] Contador de drinks servidos + volume consumido por reservatório (estimativa de estoque melhor que o sensor de 3 níveis)
- [ ] Idade/termo de responsabilidade na UI (bebida alcoólica)

## v1.0 — Escala (frota de máquinas)

- [ ] Telemetria remota (drinks servidos, níveis, erros) — MQTT ou HTTP para um backend simples
- [ ] Catálogo de drinks gerenciado remotamente (painel web do operador)
- [ ] Atualização do app via MDM/kiosk manager (ex.: Fully Kiosk, Scalefusion)
- [ ] Pagamento integrado (Pix/cartão) se o modelo de negócio for venda direta
- [ ] CI: `flutter analyze` + `flutter test` em GitHub Actions a cada PR

## Notas

- A página 8 do PDF do protótipo (CycleManager, inversor, "Posto 1/2/3", cintadeira/polionda) parece ser anotação de **outro projeto** (automação industrial/PLC) — não foi considerada aqui. Confirmar e remover do documento da máquina.
