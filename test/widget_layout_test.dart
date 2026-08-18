import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  final qrPaint = find.descendant(
    of: find.byType(XueHuaQrCode),
    matching: find.byType(CustomPaint),
  );

  testWidgets('adapts to shortest bounded constraint side', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: SizedBox(width: 200, height: 100, child: XueHuaQrCode(value: 'layout-test')),
      ),
    );

    expect(tester.getSize(qrPaint), const Size(100, 100));
  });

  testWidgets('fixed size parameter wins over constraints', (tester) async {
    await tester.pumpWidget(const Center(child: XueHuaQrCode(value: 'fixed', size: 96)));
    expect(tester.getSize(qrPaint), const Size(96, 96));
  });

  testWidgets('empty value shows errorBuilder instead of throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: XueHuaQrCode(
          value: '',
          errorBuilder: (context, error, stackTrace) => const Text('qr-error'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('qr-error'), findsOneWidget);
  });

  testWidgets('oversized value shows errorBuilder instead of throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: XueHuaQrCode(
          value: 'a' * 8000,
          errorCorrectionLevel: QrErrorLevel.high,
          errorBuilder: (context, error, stackTrace) => const Text('qr-error'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('qr-error'), findsOneWidget);
  });

  testWidgets('recovers when value changes from invalid to valid', (tester) async {
    Widget build(String value) => MaterialApp(
      home: XueHuaQrCode(
        value: value,
        errorBuilder: (context, error, stackTrace) => const Text('qr-error'),
      ),
    );

    await tester.pumpWidget(build(''));
    expect(find.text('qr-error'), findsOneWidget);

    await tester.pumpWidget(build('now-valid'));
    expect(find.text('qr-error'), findsNothing);
    expect(qrPaint, findsOneWidget);
  });

  testWidgets('style change does not rebuild matrix errors', (tester) async {
    Widget build(QrStyle style) => MaterialApp(
      home: Center(
        child: XueHuaQrCode(value: 'style-change', size: 100, style: style),
      ),
    );

    await tester.pumpWidget(build(const QrStyle()));
    await tester.pumpWidget(build(const QrStyle(shape: QrModuleShape.circle, color: Colors.blue)));
    expect(tester.takeException(), isNull);
    expect(qrPaint, findsOneWidget);
  });

  testWidgets('failing logo degrades to plain QR', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: XueHuaQrCode(
            value: 'logo-fallback',
            size: 100,
            logo: QrLogo(image: AssetImage('definitely/missing.png')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Logo 加载失败会被静默上报(测试环境中体现为一个可消费的异常),
    // 但二维码本体仍正常渲染。
    expect(tester.takeException(), isNotNull);
    expect(qrPaint, findsOneWidget);
  });

  testWidgets('logo raises effective error level to high', (tester) async {
    const withLogo = XueHuaQrCode(
      value: 'x',
      logo: QrLogo(image: AssetImage('a.png')),
    );
    const withoutLogo = XueHuaQrCode(value: 'x');
    expect(withLogo.effectiveErrorLevel, QrErrorLevel.high);
    expect(withoutLogo.effectiveErrorLevel, QrErrorLevel.medium);
  });
}
