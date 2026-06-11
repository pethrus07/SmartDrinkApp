import 'package:flutter_test/flutter_test.dart';
import 'package:smart_drink/core/machine_config.dart';
import 'package:smart_drink/core/sd_protocol.dart';

void main() {
  group('Calibration ajustavel', () {
    tearDown(Calibration.reset);

    test('mlToTimeMs reflete calibragem alterada', () {
      Calibration.msPerMl = 25;
      Calibration.valveOpenMs = 200;
      expect(mlToTimeMs(100), 2700);
    });

    test('reset volta aos valores de fabrica', () {
      Calibration.msPerMl = 99;
      Calibration.reset();
      expect(mlToTimeMs(50), 1600);
    });
  });

  group('mlToTimeMs', () {
    test('calibragem 30ms/ml + 100ms de abertura', () {
      expect(mlToTimeMs(50), 1600); // exemplo do documento do protótipo
      expect(mlToTimeMs(80), 2500); // Estrela Cadente: 80ml de vodka
    });

    test('volume zero ou negativo nao abre a valvula', () {
      expect(mlToTimeMs(0), 0);
      expect(mlToTimeMs(-10), 0);
    });
  });

  group('SdProtocol.dispenseCommand', () {
    test('sempre envia os 6 reservatorios em ordem', () {
      final cmd = SdProtocol.dispenseCommand({1: 1600, 2: 2300, 3: 2155});
      expect(cmd, '#SD;1:1600;2:2300;3:2155;4:0;5:0;6:0;/SD');
    });

    test('mapa vazio gera frame com tudo zerado', () {
      expect(
        SdProtocol.dispenseCommand({}),
        '#SD;1:0;2:0;3:0;4:0;5:0;6:0;/SD',
      );
    });
  });

  group('SdProtocol.levelRequest', () {
    test('frame de solicitacao de nivel', () {
      expect(SdProtocol.levelRequest(), '#SD;level;/SD');
    });
  });

  group('SdProtocol.parseLevels', () {
    test('resposta de nivel valida', () {
      final levels =
          SdProtocol.parseLevels('#SD;1:2;2:2;3:2;4:2;5:2;6:2;/SD');
      expect(levels, {1: 2, 2: 2, 3: 2, 4: 2, 5: 2, 6: 2});
    });

    test('resposta parcial tambem e aceita', () {
      expect(SdProtocol.parseLevels('#SD;1:0;/SD'), {1: 0});
    });

    test('frames invalidos retornam null', () {
      expect(SdProtocol.parseLevels('lixo'), isNull);
      expect(SdProtocol.parseLevels('#SD;level;/SD'), isNull);
      expect(SdProtocol.parseLevels('#SD;7:2;/SD'), isNull); // reservatorio inexistente
      expect(SdProtocol.parseLevels('#SD;a:b;/SD'), isNull);
    });
  });

  group('SdProtocol.isFrame / payloadOf', () {
    test('reconhece frames com e sem espacos', () {
      expect(SdProtocol.isFrame('  #SD;level;/SD  '), isTrue);
      expect(SdProtocol.isFrame('#SD;1:0/SD'), isTrue);
      expect(SdProtocol.isFrame('SD;level;/SD'), isFalse);
    });

    test('extrai payload sem o ; final', () {
      expect(SdProtocol.payloadOf('#SD;level;/SD'), 'level');
      expect(SdProtocol.payloadOf('#SD;1:2;2:2;/SD'), '1:2;2:2');
    });
  });
}
