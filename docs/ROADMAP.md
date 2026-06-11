# Roadmap

## 🔴 Decisões pendentes (bloqueiam a próxima fase)

1. **Canal físico tablet ↔ placa** — USB serial (OTG), Bluetooth ou WiFi/ESP32?
   Recomendação inicial: **USB serial**, por confiabilidade em operação autônoma (sem pareamento, sem queda de sinal, tablet fixo no gabinete). Implementar em `lib/hardware/usb_serial_transport.dart`.
2. **Firmware: protocolo de resposta** — alinhar `done`, erro e cancelamento (ver lacunas em PROTOCOLO.md). Sem `done`, o app só pode estimar o término por tempo.
3. **Semântica do nível dos reservatórios** — confirmar a escala (0/1/2?) com o firmware.
4. **Válvulas em sequência ou paralelo?** — afeta o tempo total exibido ao cliente. Hoje assumimos sequência (soma dos tempos).

## ✅ v0.3 — Demo funcional completa (entregue)

- [x] Bloqueio de drinks com reservatório vazio (selo "EM FALTA" + botões desabilitados)
- [x] Tela de erro de preparo ("procure o atendente") + gatilho de falha simulada no admin
- [x] Reabastecimento simulado por reservatório no admin
- [x] PIN no acesso ao painel admin (padrão 1234, persistido nas configurações)
- [x] Renomear reservatórios pelo admin (persistido)
- [x] Calibragem ajustável pelo admin (ms/ml e abertura, persistida)
- [x] Estatísticas: drinks servidos + ml por reservatório (persistidas, com zerar)
- [x] **Tela de pagamento simulada** (Pix com QR ilustrativo / cartão, preço configurável no admin)

## v0.4 — Conectar à máquina real

- [ ] Implementar o transporte escolhido (+ reconexão automática)
- [ ] Tela/banner de "máquina desconectada"
- [ ] Logs persistentes de comandos enviados (auditoria/suporte)
- [ ] Calibragem por válvula individual (hoje é global)
- [ ] Idade/termo de responsabilidade na UI (bebida alcoólica)
- [ ] PIN configurável pela interface (hoje persiste mas só muda editando o armazenamento)

## v1.0 — Escala (frota de máquinas)

- [ ] Telemetria remota (drinks servidos, níveis, erros) — MQTT ou HTTP para um backend simples
- [ ] Catálogo de drinks gerenciado remotamente (painel web do operador)
- [ ] Atualização do app via MDM/kiosk manager (ex.: Fully Kiosk, Scalefusion)
- [ ] Pagamento real (gateway Pix / maquininha) substituindo a simulação — incluir estorno automático quando o preparo falhar após pagamento aprovado
- [ ] CI: `flutter analyze` + `flutter test` em GitHub Actions a cada PR

## Notas

- A página 8 do PDF do protótipo (CycleManager, inversor, "Posto 1/2/3", cintadeira/polionda) parece ser anotação de **outro projeto** (automação industrial/PLC) — não foi considerada aqui. Confirmar e remover do documento da máquina.
