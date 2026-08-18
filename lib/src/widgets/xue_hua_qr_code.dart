import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../encoding/qr_code_enums.dart';
import '../export.dart' as qr_export;
import '../model/qr_logo.dart';
import '../model/qr_matrix.dart';
import '../model/qr_style.dart';
import '../painting/qr_painter.dart';

/// 二维码组件。仅传 [value] 即渲染标准黑白二维码,自适应父级约束。
///
/// ```dart
/// // 基础用法
/// XueHuaQrCode(value: 'https://example.com')
///
/// // 自定义样式 + Logo
/// XueHuaQrCode(
///   value: 'https://example.com',
///   size: 240,
///   style: const QrStyle(shape: QrModuleShape.roundedSquare),
///   logo: const QrLogo(image: AssetImage('assets/logo.png')),
/// )
/// ```
class XueHuaQrCode extends StatefulWidget {
  const XueHuaQrCode({
    super.key,
    required this.value,
    this.size,
    this.style = const QrStyle(),
    this.logo,
    this.errorCorrectionLevel,
    this.errorBuilder,
    this.semanticsLabel,
  });

  /// 要编码的内容(唯一必填参数)。
  final String value;

  /// 固定边长(逻辑像素);省略时取父级约束的最短边。
  final double? size;

  /// 外观样式,默认标准黑白。
  final QrStyle style;

  /// 中心 Logo;加载失败时自动降级为无 Logo 的完整二维码。
  final QrLogo? logo;

  /// 纠错等级;null 时自动:无 Logo 用 [QrErrorLevel.medium],
  /// 带 Logo 用 [QrErrorLevel.high] 以补偿被遮挡的模块。
  final QrErrorLevel? errorCorrectionLevel;

  /// 编码失败(内容为空/超长)时的降级 UI;
  /// 未提供时 debug 模式显示错误占位,release 模式显示空白。
  final ImageErrorWidgetBuilder? errorBuilder;

  /// 无障碍语义标签。
  final String? semanticsLabel;

  /// 实际生效的纠错等级。
  QrErrorLevel get effectiveErrorLevel =>
      errorCorrectionLevel ?? (logo != null ? QrErrorLevel.high : QrErrorLevel.medium);

  /// 渲染为 [ui.Image](与组件显示同一绘制实现)。
  static Future<ui.Image> toImage(
    String value, {
    double size = 512,
    QrStyle style = const QrStyle(),
    QrLogo? logo,
    QrErrorLevel? errorCorrectionLevel,
  }) => qr_export.renderQrImage(
    value,
    size: size,
    style: style,
    logo: logo,
    errorCorrectionLevel: errorCorrectionLevel,
  );

  /// 渲染为 PNG 字节,可直接保存文件或用于 `Image.memory`。
  static Future<Uint8List> toPngBytes(
    String value, {
    double size = 512,
    QrStyle style = const QrStyle(),
    QrLogo? logo,
    QrErrorLevel? errorCorrectionLevel,
  }) => qr_export.renderQrPngBytes(
    value,
    size: size,
    style: style,
    logo: logo,
    errorCorrectionLevel: errorCorrectionLevel,
  );

  @override
  State<XueHuaQrCode> createState() => _XueHuaQrCodeState();
}

class _XueHuaQrCodeState extends State<XueHuaQrCode> {
  QrMatrix? _matrix;
  Object? _error;
  StackTrace? _stackTrace;

  ImageStream? _logoStream;
  ImageStreamListener? _logoListener;
  ImageInfo? _logoInfo;

  @override
  void initState() {
    super.initState();
    _encode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖(如设备像素比)变化时解析 Logo,保证选择正确分辨率的资源。
    _resolveLogo();
  }

  @override
  void didUpdateWidget(covariant XueHuaQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 仅编码相关参数变化时重新编码;纯样式变化交给 shouldRepaint 处理。
    if (oldWidget.value != widget.value ||
        oldWidget.effectiveErrorLevel != widget.effectiveErrorLevel) {
      _encode();
    }
    if (oldWidget.logo?.image != widget.logo?.image) {
      _resolveLogo();
    }
  }

  @override
  void dispose() {
    _detachLogoStream();
    _logoInfo?.dispose();
    _logoInfo = null;
    super.dispose();
  }

  @pragma('vm:notify-debugger-on-exception')
  void _encode() {
    try {
      _matrix = QrMatrix.encode(widget.value, errorLevel: widget.effectiveErrorLevel);
      _error = null;
      _stackTrace = null;
    } catch (error, stackTrace) {
      // 捕获所有异常与 Error(如空内容、容量溢出),统一降级。
      _matrix = null;
      _error = error;
      _stackTrace = stackTrace;

      if (widget.errorBuilder == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            silent: true,
            library: 'xue_hua_qr_code',
            context: ErrorDescription('while encoding QR code'),
            exception: error,
            stack: stackTrace,
            informationCollector: () => [StringProperty('value', widget.value)],
          ),
        );
      }
    }
  }

  void _resolveLogo() {
    final provider = widget.logo?.image;
    if (provider == null) {
      _detachLogoStream();
      _logoInfo?.dispose();
      _logoInfo = null;
      return;
    }

    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _logoStream?.key) return;

    _detachLogoStream();
    _logoStream = stream;
    _logoListener = ImageStreamListener(_handleLogoFrame, onError: _handleLogoError);
    stream.addListener(_logoListener!);
  }

  void _handleLogoFrame(ImageInfo info, bool _) {
    if (!mounted) {
      info.dispose();
      return;
    }
    setState(() {
      _logoInfo?.dispose();
      _logoInfo = info;
    });
  }

  void _handleLogoError(Object error, StackTrace? stackTrace) {
    // 降级:Logo 失败时继续渲染完整二维码,不清空中心区域。
    if (mounted) {
      setState(() {
        _logoInfo?.dispose();
        _logoInfo = null;
      });
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        silent: true,
        library: 'xue_hua_qr_code',
        context: ErrorDescription('while loading QR logo image'),
        exception: error,
        stack: stackTrace,
      ),
    );
  }

  void _detachLogoStream() {
    if (_logoStream != null && _logoListener != null) {
      _logoStream!.removeListener(_logoListener!);
    }
    _logoStream = null;
    _logoListener = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    final error = _error;
    final matrix = _matrix;
    if (error != null || matrix == null) {
      final builder = widget.errorBuilder;
      final resolvedError = error ?? StateError('QR matrix unavailable');
      child = builder != null
          ? builder(context, resolvedError, _stackTrace)
          : _QrErrorPlaceholder(error: resolvedError);
    } else {
      child = CustomPaint(
        isComplex: true,
        painter: QrPainter(
          matrix: matrix,
          style: widget.style,
          logo: widget.logo,
          logoImage: _logoInfo?.image,
        ),
      );
    }

    child = Semantics(
      label: widget.semanticsLabel ?? 'QR code',
      // 无 Directionality 祖先(如纯测试环境)时兜底,避免语义断言失败。
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      image: true,
      child: child,
    );

    if (widget.size != null) {
      return SizedBox.square(dimension: widget.size, child: child);
    }

    // 自适应:取父级约束的最短有限边,均无限时不显示。
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final double side;
        if (width.isFinite && height.isFinite) {
          side = math.min(width, height);
        } else if (width.isFinite) {
          side = width;
        } else if (height.isFinite) {
          side = height;
        } else {
          side = 0;
        }
        if (side <= 0) return const SizedBox.shrink();
        // Align 使正方形内容在非正方形的紧约束中居中。
        return Align(
          child: SizedBox.square(dimension: side, child: child),
        );
      },
    );
  }
}

/// 默认错误占位:debug 显示错误信息,release 显示空白。
class _QrErrorPlaceholder extends StatelessWidget {
  const _QrErrorPlaceholder({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.expand();

    return ColoredBox(
      color: const Color(0xCF8D021F),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FittedBox(
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Color(0xFFFFFFFF), shadows: [Shadow(blurRadius: 1)]),
          ),
        ),
      ),
    );
  }
}
