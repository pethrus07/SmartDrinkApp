/// Configuração física da máquina Smart Drink.
///
/// Todos os valores de calibragem vivem aqui. Quando a calibragem
/// passar a ser configurável pelo painel admin, esta classe vira a
/// fonte dos valores padrão e o ajuste fino é persistido por máquina.
library;

/// Milissegundos de válvula aberta necessários para dispensar 1 ml.
/// Calibragem atual do protótipo: 30 ms/ml.
const int msPerMl = 30;

/// Tempo fixo de abertura/fechamento da válvula (overhead por acionamento).
const int valveOpenMs = 100;

/// Capacidade do copo servido (ml).
const int cupMl = 400;

/// Quantidade de reservatórios da máquina.
const int numReservoirs = 6;

/// Converte um volume em ml para o tempo de válvula aberta em ms.
/// Retorna 0 para volumes não positivos (válvula não abre).
int mlToTimeMs(int ml) => ml > 0 ? (ml * msPerMl) + valveOpenMs : 0;
