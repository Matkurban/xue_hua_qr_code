import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('example app renders a QR code', (WidgetTester tester) async {
    await tester.pumpWidget(const XueHuaQrCodeExampleApp());

    expect(find.byType(XueHuaQrCode), findsOneWidget);
    expect(find.text('Live widget preview'), findsOneWidget);
  });
}
