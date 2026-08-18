import 'package:xue_hua_qr_code/src/encoding/bit_buffer.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QRNumber edge cases', () {
    test('empty string', () {
      final testBuffer = BitBuffer();
      QrNumber('').write(testBuffer);
      expect(testBuffer.buffer, List<int>.filled(32, 0));
      expect(testBuffer.lengthInBits, 0);
    });
  });

  group('QRNumber positive numbers', () {
    test('0', () {
      final testBuffer = BitBuffer();
      QrNumber('0').write(testBuffer);
      expect(testBuffer.buffer, List<int>.filled(32, 0));
      expect(testBuffer.lengthInBits, 4);
    });

    test('1', () {
      final testBuffer = BitBuffer();
      QrNumber('1').write(testBuffer);
      expect(testBuffer.buffer, List<int>.filled(32, 0)..[0] = 16);
      expect(testBuffer.lengthInBits, 4);
    });

    test('123', () {
      final testBuffer = BitBuffer();
      QrNumber('123').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 30
          ..[1] = 192,
      );
      expect(testBuffer.lengthInBits, 10);
    });

    test('1234567', () {
      final testBuffer = BitBuffer();
      QrNumber('1234567').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 30
          ..[1] = 220
          ..[2] = 135,
      );
      expect(testBuffer.lengthInBits, 24);
    });

    test('9223372036854775807', () {
      final testBuffer = BitBuffer();
      QrNumber('9223372036854775807').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 230
          ..[1] = 149
          ..[2] = 19
          ..[3] = 46
          ..[4] = 173
          ..[5] = 119
          ..[6] = 100
          ..[7] = 71,
      );
      expect(testBuffer.lengthInBits, 64);
    });
  });

  group('QRNumber negative numbers', () {
    test('-1', () {
      final testBuffer = BitBuffer();
      QrNumber('-1').write(testBuffer);
      expect(testBuffer.buffer, List<int>.filled(32, 0)..[0] = 254);
      expect(testBuffer.lengthInBits, 7);
    });

    test('-123', () {
      final testBuffer = BitBuffer();
      QrNumber('-123').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 253
          ..[1] = 12,
      );
      expect(testBuffer.lengthInBits, 14);
    });

    test('-1234567', () {
      final testBuffer = BitBuffer();
      QrNumber('-1234567').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 253
          ..[1] = 21
          ..[2] = 152
          ..[3] = 96,
      );
      expect(testBuffer.lengthInBits, 27);
    });

    test('-9223372036854775807', () {
      final testBuffer = BitBuffer();
      QrNumber('-9223372036854775807').write(testBuffer);
      expect(
        testBuffer.buffer,
        List<int>.filled(32, 0)
          ..[0] = 233
          ..[1] = 14
          ..[2] = 155
          ..[3] = 65
          ..[4] = 112
          ..[5] = 136
          ..[6] = 239
          ..[7] = 96
          ..[8] = 224,
      );
      expect(testBuffer.lengthInBits, 67);
    });
  });
}
