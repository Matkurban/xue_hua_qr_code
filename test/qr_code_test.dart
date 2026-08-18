import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QrStyle', () {
    test('defaults are standard black-on-white squares', () {
      const style = QrStyle();
      expect(style.shape, QrModuleShape.square);
      expect(style.color, const Color(0xFF000000));
      expect(style.backgroundColor, const Color(0xFFFFFFFF));
      expect(style.gradient, isNull);
      expect(style.effectiveModuleRadius, 0);
      expect(style.effectiveModuleGap, 0);
    });

    test('effective values follow shape presets', () {
      expect(const QrStyle(shape: QrModuleShape.circle).effectiveModuleRadius, 0.5);
      expect(const QrStyle(shape: QrModuleShape.roundedSquare).effectiveModuleRadius, 0.3);
      expect(const QrStyle(shape: QrModuleShape.circle).effectiveModuleGap, 0.1);
    });

    test('explicit moduleRadius overrides preset', () {
      const style = QrStyle(shape: QrModuleShape.roundedSquare, moduleRadius: 0.1);
      expect(style.effectiveModuleRadius, 0.1);
    });

    test('copyWith replaces selected fields only', () {
      const base = QrStyle();
      final updated = base.copyWith(color: Colors.green, moduleGap: 0.2);
      expect(updated.color, Colors.green);
      expect(updated.moduleGap, 0.2);
      expect(updated.backgroundColor, base.backgroundColor);
    });

    test('out-of-range moduleRadius asserts', () {
      expect(() => QrStyle(moduleRadius: 0.6), throwsAssertionError);
      expect(() => QrStyle(moduleGap: -0.1), throwsAssertionError);
    });
  });

  group('QrLogo', () {
    test('oversized scale asserts', () {
      expect(
        () => QrLogo(image: const AssetImage('assets/logo.png'), scale: 0.5),
        throwsAssertionError,
      );
    });
  });

  group('export', () {
    test('toPngBytes returns PNG header', () async {
      final bytes = await XueHuaQrCode.toPngBytes('Hello world!', size: 128);
      expect(bytes.length, greaterThan(8));
      expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    test('toImage returns image of requested size', () async {
      final image = await XueHuaQrCode.toImage(
        'Hello world!',
        size: 200,
        style: const QrStyle(
          shape: QrModuleShape.roundedSquare,
          gradient: LinearGradient(colors: [Colors.pink, Colors.blue]),
        ),
      );
      expect(image.width, 200);
      expect(image.height, 200);
      image.dispose();
    });

    test('toPngBytes with failing logo still succeeds (degrades)', () async {
      final bytes = await XueHuaQrCode.toPngBytes(
        'Hello world!',
        size: 128,
        logo: const QrLogo(image: AssetImage('definitely/missing.png')),
      );
      expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    test('toPngBytes propagates encoding errors', () async {
      expect(() => XueHuaQrCode.toPngBytes(''), throwsArgumentError);
    });
  });
}
