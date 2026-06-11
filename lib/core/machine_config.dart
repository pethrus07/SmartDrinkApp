/// Configuração física da máquina Smart Drink.
///
/// Valores de fábrica são constantes; a calibragem efetiva vive em
/// [Calibration] e pode ser ajustada pelo painel admin (persistida
/// via SettingsRepository).
library;

/// Valores de fábrica (protótipo).
const int defaultMsPerMl = 30;
const int defaultValveOpenMs = 100;

/// Capacidade do copo servido (ml).
const int cupMl = 400;

/// Quantidade de reservatórios da máquina.
const int numReservoirs = 6;

/// Calibragem efetiva das válvulas (ajustável em runtime).
class Calibration {
  Calibration._();
  static int msPerMl = defaultMsPerMl;
  static int valveOpenMs = defaultValveOpenMs;

  static void reset() {
    msPerMl = defaultMsPerMl;
    valveOpenMs = defaultValveOpenMs;
  }
}

/// Calibragem atual — getters para compatibilidade com código que
/// referencia `msPerMl`/`valveOpenMs` diretamente.
int get msPerMl => Calibration.msPerMl;
int get valveOpenMs => Calibration.valveOpenMs;

/// Converte um volume em ml para o tempo de válvula aberta em ms.
/// Retorna 0 para volumes não positivos (válvula não abre).
int mlToTimeMs(int ml) =>
    ml > 0 ? (ml * Calibration.msPerMl) + Calibration.valveOpenMs : 0;
