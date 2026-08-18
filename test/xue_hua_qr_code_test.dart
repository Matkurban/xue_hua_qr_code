import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  test('public API exports work', () {
    expect(QrMatrix.encode('x'), isA<QrMatrix>());
    expect(const QrStyle(), isA<QrStyle>());
    expect(const QrLogo(image: AssetImage('a.png')), isA<QrLogo>());
    expect(QrErrorLevel.values, hasLength(4));
    expect(QrPainter(matrix: QrMatrix.encode('x')), isA<QrPainter>());
  });
}
