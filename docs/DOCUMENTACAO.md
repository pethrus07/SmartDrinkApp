# Smart Drink — Documentação do App

**Versão:** 0.3 (demo funcional completa) · **Data:** junho/2026
**Plataforma:** Flutter · roda em Chrome/desktop para demonstração e em tablet Android (kiosk) na máquina

---

## 1. Visão geral

O Smart Drink é uma máquina de drinks automatizada: um gabinete com 6 reservatórios de bebidas, válvulas eletrônicas e um tablet embutido. Este repositório contém o **app do tablet** — a interface com que o cliente monta e pede o drink, e com que o dono opera a máquina.

Nesta versão, **tudo funciona de ponta a ponta sem hardware**: a eletrônica da máquina é substituída por um simulador interno que se comporta como o firmware real (responde níveis de estoque, consome bebida a cada drink servido, sinaliza a conclusão do preparo), e o pagamento é uma simulação visual do fluxo previsto. Isso permite demonstrar o produto completo hoje e, quando a placa real estiver pronta, trocar o simulador pela comunicação física sem alterar nenhuma tela.

O estado atual foi **testado e validado** (jun/2026). O próximo ciclo é o redesign visual descrito na seção 5.

---

## 2. A jornada do cliente

O app é um ciclo fechado de telas (modo kiosk — não existe "sair"):

```
Home (vitrine) ──► Personalizar (opcional) ──► Pagamento ──► Preparo ──► Pronto ──► volta à Home
                                                                  └────► Erro ────► volta à Home
```

O cliente chega na vitrine, escolhe um drink pronto ou monta o seu, paga (Pix ou cartão — simulados), acompanha o preparo e retira o copo. Se algo falhar no preparo, uma tela orienta a procurar o atendente. O painel do dono (admin) fica atrás de um ícone discreto protegido por PIN.

---

## 3. Funcionalidades implementadas (v0.3)

### 3.1 Vitrine (Home)

- Grade de drinks com **8 receitas de fábrica** + os drinks criados pelo dono, cada card com ilustração do copo, nome, descrição, volume total e tempo de preparo.
- Card "Personalizar" para montar um drink do zero.
- Painel lateral (landscape) com o copo do drink selecionado, composição por ingrediente (cor, %, ml) e botões **Ajustar** e **Fazer drink**.
- **Controle de estoque visível:** drinks com ingrediente em falta aparecem esmaecidos com selo **"EM FALTA"** e não podem ser pedidos; o botão de fazer desabilita com aviso.
- Ícone de engrenagem (discreto) abre o admin mediante PIN.

### 3.2 Personalizar / Criar drink

- Ajuste de porção por reservatório com sliders, percentuais ao vivo e **trava no copo de 400 ml** (um ingrediente nunca pode ultrapassar o espaço restante).
- Adicionar/remover ingredientes; **reservatórios vazios não aparecem** como opção.
- Partindo de um preset ("Ajustar") ou do zero ("Personalizar").
- O dono pode **salvar a receita** com nome e descrição — ela entra na vitrine e **persiste entre reinicializações**.

### 3.3 Pagamento (simulado)

- Tela entre o "Fazer drink" e o preparo: total a pagar (preço configurável no admin, padrão R$ 15,00) e dois métodos:
  - **Pix** — exibe QR code ilustrativo e "aguardando pagamento";
  - **Cartão** — "aproxime ou insira o cartão".
- Aprovação automática após ~3 s ou imediata pelo botão **"Simular aprovação"** (atalho de demonstração); botão cancelar volta para onde o cliente estava.
- Selo "SIMULAÇÃO" visível — deixa claro em demos que não há cobrança real.
- Após aprovado: confirmação verde e transição automática para o preparo.

### 3.4 Preparo (Making)

- Anel de progresso com porcentagem e tempo restante, calculados pelo tempo real das válvulas (calibragem 30 ms/ml + 100 ms de abertura por válvula).
- Indicadores das válvulas ativas e exibição do comando enviado à máquina (`#SD;...`). *(Item marcado para sair da visão do cliente no redesign — ver seção 5.)*
- O app aguarda o sinal de conclusão da máquina (`done`), com margem de segurança por tempo caso o firmware não responda.

### 3.5 Pronto / Erro

- **Pronto:** confirmação com o comando executado e botão "Novo drink".
- **Erro:** "Ops, algo deu errado / procure o atendente", com a causa e retorno ao início. É acionada por falha real de comunicação ou pelo **gatilho de falha simulada** do admin (o preparo trava em ~40% e cai aqui — ótimo para demonstrar).

### 3.6 Painel do dono (Admin)

Protegido por **PIN de 4 dígitos com teclado numérico na tela** (padrão `1234`, persistido). Seções:

| Seção | O que faz |
|---|---|
| Gerenciar drinks | Lista e exclui as receitas criadas pelo dono |
| Reservatórios | Nível de cada um (OK / BAIXO / VAZIO), **renomear** a bebida (toque no nome) e **Reabastecer** (simulado — enche e reativa os drinks bloqueados) |
| Estatísticas | **Drinks servidos** e **ml consumidos por reservatório** (persistidos), com botão de zerar |
| Venda & Simulação | **Preço por drink** (− / +) e switch **"Simular falha no próximo drink"** |
| Protocolo | Referência dos frames de comunicação |
| Calibragem | **Editável:** ms/ml e tempo de abertura com steppers; vale para todos os cálculos e fica salvo |
| Teste de válvulas | Aciona uma válvula isolada com volume escolhido no slider (10–200 ml) e mostra o comando enviado |

### 3.7 Persistência (local, sobrevive a reinício)

- Drinks criados pelo dono.
- Configurações: calibragem, preço, PIN, nomes dos reservatórios.
- Estatísticas de operação.
- Armazenamento em `SharedPreferences` (JSON) — suficiente para uma máquina; a camada de repositório permite trocar por banco/sync sem tocar no resto.

### 3.8 Simulador da máquina

- Responde à solicitação de níveis; **consome estoque** a cada drink (nível cai OK → BAIXO → VAZIO); emite `#SD;done;/SD` ao concluir o preparo no tempo certo; aceita reabastecimento.
- É o que permite a demo completa rodar em qualquer PC/navegador.

---

## 4. Como o app está estruturado

### 4.1 Princípio

As duas coisas que mais vão mudar na vida do produto são **(a)** o canal físico de comunicação com a placa e **(b)** a configuração/catálogo por máquina. A arquitetura isola exatamente esses dois pontos. Regra de dependência:

```
UI (screens/widgets) → services → hardware/data → core
```

Telas nunca montam frames de protocolo nem falam com o transporte; o protocolo nunca depende de Flutter.

### 4.2 Estrutura de pastas

```
lib/
├── main.dart                 # composição: transporte → serviço → provider (flag USE_MOCK)
├── app.dart                  # MaterialApp + roteador de telas por estado (enum)
│
├── core/                     # Dart puro, testável sem Flutter
│   ├── machine_config.dart   #   constantes físicas + calibragem ajustável (Calibration)
│   └── sd_protocol.dart      #   frames #SD;...;/SD — montagem e parse
│
├── hardware/                 # canal de comunicação com a máquina
│   ├── machine_transport.dart      # interface (contrato)
│   ├── mock_transport.dart         # SIMULADOR (níveis, consumo, done)
│   └── usb_serial_transport.dart   # stub do canal real (decisão pendente)
│
├── services/
│   ├── machine_service.dart  # ÚNICO ponto que fala com hardware (timeout, progresso, refill)
│   └── drink_provider.dart   # estado da UI: navegação, drink ativo, pagamento, erro,
│                             # estatísticas, configurações (ChangeNotifier/provider)
├── data/
│   ├── drink_repository.dart     # persistência dos drinks do dono
│   └── settings_repository.dart  # calibragem, preço, PIN, nomes, estatísticas
│
├── models/
│   └── drink_models.dart     # Ingredient, DrinkPortion, DrinkPreset (+JSON), presets
│
├── theme/sd_theme.dart       # identidade visual centralizada (cores, tipografia, decorações)
├── screens/                  # home, customize, create_drink, payment, making, done, error, admin
└── widgets/                  # drink_card, cup_widget, drink_illustration, neon_button, pin_dialog

test/sd_protocol_test.dart    # testes do protocolo e da calibragem
docs/                         # PROTOCOLO.md, ARQUITETURA.md, ROADMAP.md, este documento
```

### 4.3 O protocolo `#SD` (contrato com o firmware)

Frames de texto delimitados por `#SD;` e `/SD`:

| Frame | Direção | Exemplo |
|---|---|---|
| Dispensar | app → máquina | `#SD;1:1600;2:2300;3:0;4:0;5:0;6:0;/SD` (reservatório:tempo_ms, sempre os 6) |
| Pedir níveis | app → máquina | `#SD;level;/SD` |
| Resposta de níveis | máquina → app | `#SD;1:2;2:2;3:1;4:0;5:2;6:2;/SD` (2=ok, 1=baixo, 0=vazio) |
| Conclusão | máquina → app | `#SD;done;/SD` *(proposto; o simulador já implementa)* |

Conversão volume→tempo: `tempo_ms = ml × msPerMl + valveOpenMs` (padrão 30 e 100, ajustáveis no admin). É a parte mais testada do código por ser onde um bug custa um drink errado servido. Lacunas a alinhar com o firmware (erro, cancelamento, checksum) estão em `docs/PROTOCOLO.md`.

### 4.4 O caminho de um pedido (de ponta a ponta)

1. Cliente toca **Fazer drink** → `DrinkProvider.goToPayment()` valida volume e estoque.
2. Pagamento aprovado → `confirmPayment()` → `makeDrink()`.
3. O provider pede ao `MachineService` o frame de dispensa e o envia pelo `MachineTransport` (hoje, o simulador).
4. O serviço estima o progresso pelo tempo total e aguarda o `done` da máquina (com timeout de segurança).
5. Sucesso → estatísticas registradas e persistidas → tela Pronto → níveis de estoque relidos. Falha → tela de Erro.

### 4.5 Como rodar

```bash
flutter create . --platforms=web      # 1ª vez (ou windows/android)
flutter pub get
flutter run -d chrome                 # demo no PC
flutter test                          # testes do protocolo
```

A máquina simulada é o padrão; `--dart-define=USE_MOCK=false` ativará o transporte real quando ele existir. Evitar rodar o projeto dentro de OneDrive ou caminhos com acento (quebra o serviço de debug do Flutter no Windows).

---

## 5. Melhorias planejadas — Redesign visual (v0.4)

> Origem: validação de jun/2026. **Funcionalidades aprovadas** — os pontos abaixo são exclusivamente de apresentação visual e linguagem. Arquitetura, fluxo e regras não mudam.

### 5.1 Diagnóstico

O tema atual é escuro/industrial com estética **neon**: bordas brilhantes, tudo em caps lock com espaçamento largo, números técnicos espalhados (ms, %, strings de comando). Funciona como painel de máquina, não como produto comercial. Direção desejada: **amigável, comercial, simples, limpo e moderno.**

### 5.2 Tema geral

| Hoje | Como deve ficar |
|---|---|
| Fundo escuro chapado + neon | Base clara (ou dark suave) com acentos coloridos |
| Bordas com glow | Sombras suaves, cards "flutuando", sem contorno neon |
| TUDO EM CAPS espaçado | Sentence case ("Escolha seu drink"); caps só em micro-rótulos |
| Tipografia pesada/condensada | Fonte arredondada e amigável (Poppins, Nunito ou Baloo 2 — google_fonts já está no projeto) |
| Cantos 12–14 px | Cantos generosos (20–28 px), botões em pílula |

**Direções possíveis (decidir uma):**

- **A — Clean claro "juice bar"** *(recomendada)*: fundo off-white, cards brancos com sombra suave, cor de destaque por drink. Máxima leitura de "comercial e amigável".
- **B — Dark premium suave**: mantém o escuro (conversa com o gabinete preto da máquina), mas troca neon por gradientes suaves. Clima "bar à noite".
- **C — Vibrante festivo**: gradientes coloridos de fundo, para eventos/festas.

⚠️ O gabinete físico é preto com ciano neon — decidir se o app **acompanha a máquina** (B) ou **contrasta para acolher** (A/C). É decisão de marca.

### 5.3 Representação dos drinks (mais chamativa)

- A ilustração do copo vira o **protagonista do card**: maior, com **gradiente nas cores reais dos ingredientes** da receita, guarnição (rodela de limão, canudo, gelo) e leve animação na seleção.
- Card simplificado: ilustração + nome + **uma** linha secundária. Sai do card a barra de ingredientes, os ml e os segundos — informação demais para a vitrine.
- Médio prazo (fora deste ciclo): ilustrações próprias por receita ou fotos reais.

### 5.4 Simplificação da linguagem (cliente ≠ técnico)

- **Esconder a string `#SD;...`** das telas de preparo e conclusão → vira "modo debug" dentro do admin.
- Remover ms/contagens técnicas da visão do cliente; no preparo, **animação amigável de copo enchendo** com frase simpática, no lugar do anel com porcentagem.
- Tela Pronto mais celebrativa ("Prontinho! Pegue seu copo") e menos relatório.
- **Admin permanece denso e técnico** — é ferramenta do dono; recebe só o novo tema.

### 5.5 Decisões pendentes antes de executar

1. Direção visual: **A, B ou C?**
2. Existe identidade de marca (logo/paleta oficial) ou o app propõe?
3. Referências de apps cujo visual vocês gostam (acelera acertar de primeira).

### 5.6 Plano de execução (ordem e arquivos)

| # | Etapa | Arquivos |
|---|---|---|
| 1 | Novos tokens: paleta, fonte, raios, sombras | `theme/sd_theme.dart` |
| 2 | Copos novos (gradiente, guarnição, animação) | `widgets/drink_illustration.dart`, `widgets/cup_widget.dart` |
| 3 | Telas do cliente | `home` → `customize`/`create_drink` → `payment` → `making` → `done`/`error` |
| 4 | Admin: tema + "modo debug" (string de comando) | `screens/admin_screen.dart` |
| 5 | Revisão de microcopy (todos os textos) | telas em geral |

Como o tema é centralizado e as telas só consomem tokens, a etapa 1 já transforma a cara do app inteiro; as demais são refinamento.

---

## 6. Depois do redesign (roadmap resumido)

1. **Conectar à máquina real** — implementar o transporte físico escolhido (recomendação: USB serial), banner de "máquina desconectada", logs de comandos. Decisões pendentes com o firmware: frame de conclusão/erro/cancelamento e semântica dos níveis.
2. **Operação comercial** — pagamento real (gateway Pix/maquininha) substituindo a simulação, **incluindo estorno automático se o preparo falhar após pagamento aprovado**; termo de idade (bebida alcoólica); PIN configurável pela interface.
3. **Escala (frota)** — telemetria remota, catálogo gerenciado por painel web, atualização via MDM, CI com `flutter analyze` + `flutter test`.

Detalhes completos em `docs/ROADMAP.md` e `docs/PROTOCOLO.md`.
