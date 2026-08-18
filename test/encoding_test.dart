import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_qr_code/src/encoding/mask_evaluation.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_code_enums.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_code_processor.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_code_square.dart';
import 'package:xue_hua_qr_code/src/encoding/qr_util.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  group('QrUtil data type detection', () {
    test('numeric strings use numbers mode', () {
      expect(QrUtil.getDataType('12345'), QrCodeDataType.numbers);
    });

    test('uppercase alphanumeric strings use upperAlphaNum mode', () {
      expect(QrUtil.getDataType('HELLO WORLD'), QrCodeDataType.upperAlphaNum);
    });

    test('mixed case urls use default 8-bit mode', () {
      expect(QrUtil.getDataType('https://example.com/path?foo=bar'), QrCodeDataType.defaultType);
    });
  });

  group('minTypeForData', () {
    test('short payload selects version 1', () {
      expect(QrCodeProcessor.minTypeForData('HELLO', QrErrorLevel.low), 1);
    });

    test('large payload selects a higher version', () {
      final data = 'https://example.com/${'a' * 64}';
      final type = QrCodeProcessor.minTypeForData(data, QrErrorLevel.low);
      expect(type, greaterThan(3));
    });

    test('higher error level needs a larger version for same data', () {
      final data = 'https://example.com/${'a' * 64}';
      final low = QrCodeProcessor.minTypeForData(data, QrErrorLevel.low);
      final high = QrCodeProcessor.minTypeForData(data, QrErrorLevel.high);
      expect(high, greaterThanOrEqualTo(low));
    });
  });

  group('QrMatrix.encode', () {
    test('module count matches version formula', () {
      final matrix = QrMatrix.encode('Hello world!');
      expect(matrix.moduleCount, matrix.version * 4 + 17);
    });

    test('empty value throws ArgumentError', () {
      expect(() => QrMatrix.encode(''), throwsArgumentError);
    });

    test('oversized value throws InsufficientInformationDensityException', () {
      expect(
        () => QrMatrix.encode('a' * 8000, errorLevel: QrErrorLevel.high),
        throwsA(isA<InsufficientInformationDensityException>()),
      );
    });

    test('timing pattern alternates on row 6', () {
      final matrix = QrMatrix.encode('Hello world!');
      expect(matrix.isDark(6, 8), isTrue);
      expect(matrix.isDark(6, 9), isFalse);
      expect(matrix.isDark(6, 10), isTrue);
    });

    test('dark module next to bottom-left finder is always dark', () {
      final matrix = QrMatrix.encode('Hello world!');
      expect(matrix.isDark(matrix.moduleCount - 8, 8), isTrue);
    });

    test('version 1 has no alignment patterns', () {
      final matrix = QrMatrix.encode('HI', errorLevel: QrErrorLevel.low);
      expect(matrix.version, 1);
      expect(matrix.alignmentCenters, isEmpty);
    });

    test('version 2+ exposes non-overlapping alignment centers', () {
      final matrix = QrMatrix.encode('https://example.com/${'a' * 24}');
      expect(matrix.version, greaterThanOrEqualTo(2));
      expect(matrix.alignmentCenters, isNotEmpty);
      for (final (row, col) in matrix.alignmentCenters) {
        expect(matrix.isInFinderPattern(row, col), isFalse);
        // 对齐图案中心模块必为深色。
        expect(matrix.isDark(row, col), isTrue);
      }
    });

    test('equal value and level produce equal matrices', () {
      final a = QrMatrix.encode('same');
      final b = QrMatrix.encode('same');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == QrMatrix.encode('same', errorLevel: QrErrorLevel.high), isFalse);
    });

    test('selected mask penalty is not worse than every fixed mask', () {
      const value = 'https://example.com/mask-check';
      final processor = QrCodeProcessor(value, errorLevel: QrErrorLevel.medium);
      final version = QrCodeProcessor.minTypeForData(value, QrErrorLevel.medium);
      final scores = MaskPattern.values
          .map((mask) => maskPenaltyScore(processor.encode(type: version, maskPattern: mask)))
          .toList();
      final best = scores.reduce((a, b) => a < b ? a : b);

      // QrMatrix 选中的矩阵罚分应等于全部掩码中的最小值。
      final matrix = QrMatrix.encode(value);
      final chosen = _scoreOfMatrix(matrix);
      expect(chosen, best);
    });
  });

  group('maskPenaltyScore', () {
    test('uniform matrix scores worse than checkerboard', () {
      final uniform = _rawData(8, (row, col) => true);
      final checker = _rawData(8, (row, col) => (row + col) % 2 == 0);
      expect(maskPenaltyScore(uniform), greaterThan(maskPenaltyScore(checker)));
    });
  });
}

/// 用 QrMatrix 的位图重建 raw data 以复用罚分函数。
int _scoreOfMatrix(QrMatrix matrix) {
  final raw = _rawData(matrix.moduleCount, matrix.isDark);
  return maskPenaltyScore(raw);
}

List<List<QrCodeSquare>> _rawData(int size, bool Function(int row, int col) dark) {
  return List.generate(
    size,
    (row) => List.generate(
      size,
      (col) => QrCodeSquare(dark: dark(row, col), row: row, col: col, moduleSize: size),
    ),
  );
}
