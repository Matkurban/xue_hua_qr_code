import 'dart:typed_data';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const data = 'https://example.com/xue-hua-qr-code';

  group('XueHuaQrCode widget', () {
    testWidgets('renders basic QR for a URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: XueHuaQrCode(
                key: ValueKey('basic_qr'),
                value: data,
                size: 200,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('basic_qr')), findsOneWidget);
      expect(find.byType(XueHuaQrCode), findsOneWidget);
    });

    testWidgets('applies circle / rounded / gradient styles', (tester) async {
      for (final style in <QrStyle>[
        const QrStyle(shape: QrModuleShape.circle, color: Colors.blue),
        const QrStyle(shape: QrModuleShape.roundedSquare, moduleRadius: 0.4),
        const QrStyle(
          shape: QrModuleShape.roundedSquare,
          backgroundColor: Colors.black,
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.blue],
          ),
        ),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: XueHuaQrCode(
                  key: const ValueKey('styled_qr'),
                  value: data,
                  size: 180,
                  style: style,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('styled_qr')), findsOneWidget);
      }
    });

    testWidgets('empty value uses errorBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: XueHuaQrCode(
                value: '',
                size: 120,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, key: ValueKey('empty_error')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('empty_error')), findsOneWidget);
    });
  });

  group('export APIs', () {
    testWidgets('toPngBytes returns non-empty PNG', (tester) async {
      final bytes = await XueHuaQrCode.toPngBytes(data, size: 256);
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(100));
      // PNG magic
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    testWidgets('toImage returns square raster', (tester) async {
      final image = await XueHuaQrCode.toImage(data, size: 128);
      expect(image.width, 128);
      expect(image.height, 128);
      image.dispose();
    });

    testWidgets('styled export with gradient still yields PNG', (tester) async {
      final bytes = await XueHuaQrCode.toPngBytes(
        data,
        size: 200,
        style: const QrStyle(
          shape: QrModuleShape.circle,
          gradient: LinearGradient(colors: [Colors.orange, Colors.purple]),
        ),
      );
      expect(bytes.length, greaterThan(100));
    });
  });

  group('example app UI', () {
    testWidgets('tabs, preview, and export PNG flow', (tester) async {
      await tester.pumpWidget(const XueHuaQrCodeExampleApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('app_title')), findsOneWidget);
      expect(find.byKey(const ValueKey('style_tabs')), findsOneWidget);
      expect(find.byKey(const ValueKey('qr_preview')), findsOneWidget);
      expect(find.byKey(const ValueKey('export_png')), findsOneWidget);

      // Switch through style tabs.
      for (final label in ['Circle', 'Rounded', 'Gradient', 'Logo', 'Basic']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('qr_preview')), findsOneWidget);
      }

      await tester.tap(find.byKey(const ValueKey('export_png')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const ValueKey('exported_png')), findsOneWidget);
    });
  });
}
