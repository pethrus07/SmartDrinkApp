import 'package:flutter_test/flutter_test.dart';
import 'package:smart_drink/core/admin_pin.dart';
import 'package:smart_drink/data/settings_repository.dart';

void main() {
  group('PIN do admin', () {
    test('a máquina sai de fábrica com o PIN padrão e exige troca', () {
      final s = AppSettings.defaults();
      expect(s.adminPin, defaultAdminPin);
      expect(mustChangeAdminPin(s.adminPin), isTrue);
    });

    test('PIN trocado não exige troca de novo', () {
      expect(mustChangeAdminPin('5820'), isFalse);
    });

    test('o PIN padrão nunca é aceito como PIN novo', () {
      expect(validateNewAdminPin(defaultAdminPin), isNotNull);
    });

    test('PIN novo precisa ter 4 dígitos numéricos', () {
      expect(validateNewAdminPin('12'), isNotNull);
      expect(validateNewAdminPin('12a4'), isNotNull);
      expect(validateNewAdminPin('12345'), isNotNull);
    });

    test('dígitos todos iguais são recusados', () {
      expect(validateNewAdminPin('0000'), isNotNull);
    });

    test('PIN válido é aceito', () {
      expect(validateNewAdminPin('5820'), isNull);
    });

    test('PIN trocado sobrevive à ida e volta do JSON', () {
      final s = AppSettings.defaults()..adminPin = '5820';
      final lido = AppSettings.fromJson(s.toJson());
      expect(lido.adminPin, '5820');
    });
  });
}
