import 'package:xue_hua_qr_code/src/encoding/polynomial.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_math.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> inputArray(List<int> values) => values.map(QrMath.gexp).toList();

void main() {
  group('Polynomial creation', () {
    test('simple', () {
      final result = Polynomial([1, 2, 3]);
      expect(result.data, [1, 2, 3]);
    });

    test('simple with 0', () {
      final result = Polynomial([0, 1, 2]);
      expect(result.data, [1, 2]);
    });

    test('only 0s', () {
      final result = Polynomial([0, 0, 0]);
      expect(result.data, [0, 0, 0]);
    });

    test('shifted 1', () {
      final result = Polynomial([1, 2, 3], 1);
      expect(result.data, [1, 2, 3, 0]);
    });

    test('shifted 3', () {
      final result = Polynomial([1, 2, 3], 3);
      expect(result.data, [1, 2, 3, 0, 0, 0]);
    });

    test('shifted 1 with 0', () {
      final result = Polynomial([0, 1, 2], 1);
      expect(result.data, [1, 2, 0]);
    });

    test('shifted 5 with 0', () {
      final result = Polynomial([0, 1, 2], 5);
      expect(result.data, [1, 2, 0, 0, 0, 0, 0]);
    });

    test('shifted 2 with 2 zeroes', () {
      final result = Polynomial([0, 0, 1], 2);
      expect(result.data, [1, 0, 0]);
    });
  });

  group('Polynomial operations', () {
    test('mod', () {
      final inputPolynomial = Polynomial(
        inputArray([
          0,
          43,
          139,
          206,
          78,
          43,
          239,
          123,
          206,
          214,
          147,
          24,
          99,
          150,
          39,
          243,
          163,
          136,
        ]),
      );
      final dataPolynomial = Polynomial([
        32,
        65,
        205,
        69,
        41,
        220,
        46,
        128,
        236,
      ], inputPolynomial.len() - 1);
      final result = dataPolynomial.mod(inputPolynomial);
      expect(result.data, [
        42,
        159,
        74,
        221,
        244,
        169,
        239,
        150,
        138,
        70,
        237,
        85,
        224,
        96,
        74,
        219,
        61,
      ]);
    });

    test('multiply', () {
      var result = Polynomial([1]);
      for (var i = 0; i <= 6; i++) {
        result = result.multiply(Polynomial([1, QrMath.gexp(i)]));
      }
      expect(result.data, [1, 127, 122, 154, 164, 11, 68, 117]);
    });
  });
}
