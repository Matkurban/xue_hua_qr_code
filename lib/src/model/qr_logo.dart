import 'package:flutter/widgets.dart';

/// 二维码中心 Logo 配置。
///
/// Logo 尺寸以二维码内容边长的比例([scale])表示,
/// 组件显示与 PNG 导出中的占比完全一致。
/// Logo 加载失败时组件自动降级为无 Logo 的完整二维码,保证可扫描。
@immutable
class QrLogo {
  const QrLogo({
    required this.image,
    this.scale = 0.2,
    this.padding = 4,
    this.backgroundColor,
    this.borderRadius = 0,
  }) : assert(
         scale > 0 && scale <= 0.35,
         'scale must be within 0~0.35; larger logos break scannability / 过大的 Logo 会破坏可扫性',
       ),
       assert(padding >= 0, 'padding must be >= 0'),
       assert(borderRadius >= 0, 'borderRadius must be >= 0');

  /// Logo 图片,支持 AssetImage / NetworkImage / MemoryImage 等。
  final ImageProvider image;

  /// Logo 边长占二维码内容边长的比例,默认 0.2,上限 0.35。
  final double scale;

  /// Logo 四周底衬留白(逻辑像素)。
  final double padding;

  /// 底衬颜色;null 时使用样式的背景色。
  final Color? backgroundColor;

  /// 底衬圆角(逻辑像素)。
  final double borderRadius;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrLogo &&
          image == other.image &&
          scale == other.scale &&
          padding == other.padding &&
          backgroundColor == other.backgroundColor &&
          borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(image, scale, padding, backgroundColor, borderRadius);
}
