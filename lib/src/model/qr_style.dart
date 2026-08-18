import 'package:flutter/widgets.dart';

/// 模块形状预设。
enum QrModuleShape {
  /// 方形模块(默认)。
  square,

  /// 圆形模块。
  circle,

  /// 圆角方形模块。
  roundedSquare,
}

/// 二维码外观样式。所有字段均有合理默认值,`const QrStyle()` 即为标准黑白样式。
@immutable
class QrStyle {
  const QrStyle({
    this.shape = QrModuleShape.square,
    this.color = const Color(0xFF000000),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.gradient,
    this.moduleRadius,
    this.moduleGap,
    this.padding = const EdgeInsets.all(8),
  }) : assert(
         moduleRadius == null || (moduleRadius >= 0 && moduleRadius <= 0.5),
         'moduleRadius must be within 0~0.5 (fraction of module size)',
       ),
       assert(
         moduleGap == null || (moduleGap >= 0 && moduleGap <= 0.5),
         'moduleGap must be within 0~0.5 (fraction of module size)',
       );

  /// 模块形状。
  final QrModuleShape shape;

  /// 前景色(深色模块)。设置 [gradient] 时被忽略。
  final Color color;

  /// 背景色。默认白色,保证深色主题下仍可扫描;
  /// 需要透明背景时显式传入 `Colors.transparent`。
  final Color backgroundColor;

  /// 前景渐变。设置后覆盖 [color],经 shader 一次性着色,渐变平滑。
  final Gradient? gradient;

  /// 模块圆角,取值 0~0.5,为模块尺寸的比例;null 时按 [shape] 自动。
  final double? moduleRadius;

  /// 模块间距,取值 0~0.5,为模块尺寸的比例;null 时按 [shape] 自动。
  final double? moduleGap;

  /// 二维码四周的静默区(quiet zone),以逻辑像素计,同时作用于组件与导出。
  final EdgeInsets padding;

  /// 实际生效的模块圆角比例。
  double get effectiveModuleRadius =>
      moduleRadius ??
      switch (shape) {
        QrModuleShape.square => 0.0,
        QrModuleShape.circle => 0.5,
        QrModuleShape.roundedSquare => 0.3,
      };

  /// 实际生效的模块间距比例。
  double get effectiveModuleGap =>
      moduleGap ??
      switch (shape) {
        QrModuleShape.square => 0.0,
        QrModuleShape.circle => 0.1,
        QrModuleShape.roundedSquare => 0.1,
      };

  /// 返回替换指定字段后的副本。
  QrStyle copyWith({
    QrModuleShape? shape,
    Color? color,
    Color? backgroundColor,
    Gradient? gradient,
    double? moduleRadius,
    double? moduleGap,
    EdgeInsets? padding,
  }) {
    return QrStyle(
      shape: shape ?? this.shape,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      moduleRadius: moduleRadius ?? this.moduleRadius,
      moduleGap: moduleGap ?? this.moduleGap,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrStyle &&
          shape == other.shape &&
          color == other.color &&
          backgroundColor == other.backgroundColor &&
          gradient == other.gradient &&
          moduleRadius == other.moduleRadius &&
          moduleGap == other.moduleGap &&
          padding == other.padding;

  @override
  int get hashCode =>
      Object.hash(shape, color, backgroundColor, gradient, moduleRadius, moduleGap, padding);
}
