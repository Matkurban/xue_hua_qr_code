import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'encoding/qr_code_enums.dart';
import 'model/qr_logo.dart';
import 'model/qr_matrix.dart';
import 'model/qr_style.dart';
import 'painting/qr_painter.dart';

/// 将 [value] 渲染为 [ui.Image],与组件显示共用 [QrPainter],所见即所得。
///
/// [size] 为输出图片边长(像素)。Logo 加载失败时自动降级为无 Logo 图片。
/// 编码失败(内容为空或超长)时抛出异常,由调用方处理。
Future<ui.Image> renderQrImage(
  String value, {
  double size = 512,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  QrErrorLevel? errorCorrectionLevel,
}) async {
  assert(size > 0, 'size must be > 0');
  final level = errorCorrectionLevel ?? (logo != null ? QrErrorLevel.high : QrErrorLevel.medium);
  final matrix = QrMatrix.encode(value, errorLevel: level);

  ui.Image? logoImage;
  if (logo != null) {
    try {
      logoImage = await resolveImageProvider(logo.image);
    } catch (error, stackTrace) {
      // 降级:Logo 加载失败时输出完整的无 Logo 二维码。
      FlutterError.reportError(
        FlutterErrorDetails(
          silent: true,
          library: 'xue_hua_qr_code',
          context: ErrorDescription('while resolving QR logo image for export'),
          exception: error,
          stack: stackTrace,
        ),
      );
    }
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  QrPainter(
    matrix: matrix,
    style: style,
    logo: logo,
    logoImage: logoImage,
  ).paint(canvas, Size.square(size));

  final picture = recorder.endRecording();
  final pixels = size.ceil();
  final image = await picture.toImage(pixels, pixels);
  picture.dispose();
  return image;
}

/// 将 [value] 渲染为 PNG 字节,参数与 [renderQrImage] 一致。
Future<Uint8List> renderQrPngBytes(
  String value, {
  double size = 512,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  QrErrorLevel? errorCorrectionLevel,
}) async {
  final image = await renderQrImage(
    value,
    size: size,
    style: style,
    logo: logo,
    errorCorrectionLevel: errorCorrectionLevel,
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (byteData == null) {
    throw StateError('Failed to encode QR code as PNG');
  }
  return byteData.buffer.asUint8List();
}

/// 将 [ImageProvider] 解析为 [ui.Image](一次性,非组件生命周期用途)。
Future<ui.Image> resolveImageProvider(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info.image);
      stream.removeListener(listener);
    },
    onError: (Object error, StackTrace? stackTrace) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace ?? StackTrace.current);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
