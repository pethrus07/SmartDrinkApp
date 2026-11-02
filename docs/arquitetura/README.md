# Arquitetura

Três vistas do sistema, cada uma numa notação padrão.

| Vista | Notação | Responde |
|---|---|---|
| Casos de uso | UML | Quem usa e para quê |
| Processo | BPMN 2.0 | Como o trabalho anda, com uma raia para cada quem executa |
| Arquitetura | C4, nível 2 | De que partes o sistema é feito e com quem conversa |

## Smart Drink · app da máquina de drinks

App Flutter em modo kiosk, no tablet da máquina Smart Drink: o cliente escolhe e ajusta o drink, paga por Pix ou cartão (ainda simulado) e a máquina dosa de 6 reservatórios. Hoje roda inteiro com a máquina simulada.

### Quem usa e para quê

![Casos de uso de Smart Drink](./smart-drink-1-casos-de-uso.svg)

### Do toque na tela ao drink pronto

![Processo de Smart Drink](./smart-drink-2-processo.svg)

### Arquitetura

![Arquitetura de Smart Drink](./smart-drink-3-arquitetura.svg)

Para editar: [smart-drink.excalidraw](./smart-drink.excalidraw), que abre em [excalidraw.com](https://excalidraw.com) ou na extensão Excalidraw do VS Code.

## De onde vêm

Os diagramas são gerados a partir do Sinapse, o vault onde o Pedro organiza notas e projetos. Mudança feita direto aqui some na próxima publicação: o lugar de mudar é a especificação no Sinapse.
