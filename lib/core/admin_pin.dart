/// Regras do PIN do painel admin (Dart puro, testável).
///
/// A máquina sai de fábrica com [defaultAdminPin]. Enquanto ele estiver em
/// uso, o app obriga o owner a escolher um PIN novo no primeiro acesso ao
/// painel; o PIN padrão nunca serve como PIN definitivo.
library;

/// PIN de fábrica (só vale para o primeiro acesso).
const String defaultAdminPin = '1234';

/// Tamanho do PIN.
const int adminPinLength = 4;

/// `true` enquanto o PIN em uso for o de fábrica.
bool mustChangeAdminPin(String currentPin) => currentPin == defaultAdminPin;

/// Valida um PIN novo. Devolve `null` se aceito ou a mensagem de erro.
String? validateNewAdminPin(String pin) {
  if (pin.length != adminPinLength || !RegExp(r'^\d+$').hasMatch(pin)) {
    return 'O PIN precisa ter $adminPinLength dígitos';
  }
  if (pin == defaultAdminPin) return 'Escolha um PIN diferente do padrão';
  if (RegExp(r'^(\d)\1+$').hasMatch(pin)) {
    return 'Evite dígitos todos iguais';
  }
  return null;
}
