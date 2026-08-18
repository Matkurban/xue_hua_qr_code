import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../model/qr_logo.dart';
import '../model/qr_matrix.dart';
import '../model/qr_style.dart';

/// 无状态的二维码绘制器。组件显示与 PNG 导出共用同一实现,保证所见即所得。
///
/// 所有几何量使用 double 精度按可用空间等比计算,任意尺寸下都能铺满且不残留。
class QrPainter extends CustomPainter {
  const QrPainter({required this.matrix, this.style = const QrStyle(), this.logo, this.logoImage});

  /// 编码结果。
  final QrMatrix matrix;

  /// 外观样式。
  final QrStyle style;

  /// Logo 配置;仅当 [logoImage] 已解析成功时才实际绘制。
  final QrLogo? logo;

  /// 已解析的 Logo 图片。为 null 时(未加载完成或加载失败)
  /// 绘制完整二维码,不清空中心区域,保证始终可扫。
  final ui.Image? logoImage;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // 背景铺满整个绘制区域(含静默区)。
    if (style.backgroundColor.a > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = style.backgroundColor);
    }

    // 去掉静默区后,取最短边居中得到正方形内容区。
    final inner = style.padding.deflateRect(Offset.zero & size);
    if (inner.isEmpty) return;
    final contentSide = inner.shortestSide;
    final contentRect = Rect.fromCenter(
      center: inner.center,
      width: contentSide,
      height: contentSide,
    );

    final n = matrix.moduleCount;
    final cell = contentSide / n;

    // Logo 底衬区域;其覆盖的模块直接跳过,避免模块透出。
    Rect? logoRect;
    Rect? backdropRect;
    final activeLogo = logo;
    if (activeLogo != null && logoImage != null) {
      final logoSide = contentSide * activeLogo.scale;
      logoRect = Rect.fromCenter(center: contentRect.center, width: logoSide, height: logoSide);
      backdropRect = logoRect.inflate(activeLogo.padding);
    }

    final radiusRatio = style.effectiveModuleRadius;
    final gapInset = cell * style.effectiveModuleGap / 2;

    // 所有前景几何合入一个 evenOdd Path:
    // 定位/对齐图案的"回"字环通过外框 + 内孔的奇偶规则成型,
    // 单次 drawPath 即可让纯色或渐变均匀作用于全部前景。
    final path = Path()..fillType = PathFillType.evenOdd;

    Rect cellRect(int row, int col, int span) => Rect.fromLTWH(
      contentRect.left + col * cell,
      contentRect.top + row * cell,
      cell * span,
      cell * span,
    );

    void addRounded(Rect rect, double ratio) {
      final radius = ratio * rect.shortestSide;
      if (radius <= 0) {
        path.addRect(rect);
      } else {
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      }
    }

    // 定位图案:7x7 外环(壁厚 1 模块)+ 3x3 实心。
    for (final (row, col) in matrix.finderOrigins) {
      addRounded(cellRect(row, col, 7), radiusRatio);
      addRounded(cellRect(row + 1, col + 1, 5), radiusRatio);
      addRounded(cellRect(row + 2, col + 2, 3), radiusRatio);
    }

    // 对齐图案:5x5 外环 + 中心 1 模块。
    for (final (centerRow, centerCol) in matrix.alignmentCenters) {
      final origin = cellRect(centerRow - 2, centerCol - 2, 5);
      if (backdropRect != null && origin.overlaps(backdropRect)) continue;
      addRounded(origin, radiusRatio);
      addRounded(cellRect(centerRow - 1, centerCol - 1, 3), radiusRatio);
      addRounded(cellRect(centerRow, centerCol, 1), radiusRatio);
    }

    // 数据/时序/格式模块:逐模块按形状绘制,带间距与圆角。
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        if (!matrix.isDark(row, col)) continue;
        if (matrix.isInFinderPattern(row, col)) continue;
        if (matrix.isInAlignmentPattern(row, col)) continue;

        final rect = cellRect(row, col, 1).deflate(gapInset);
        if (backdropRect != null && rect.overlaps(backdropRect)) continue;

        switch (style.shape) {
          case QrModuleShape.square:
            if (radiusRatio > 0) {
              addRounded(rect, radiusRatio);
            } else {
              path.addRect(rect);
            }
          case QrModuleShape.circle:
            path.addOval(rect);
          case QrModuleShape.roundedSquare:
            addRounded(rect, radiusRatio);
        }
      }
    }

    final fgPaint = Paint()..isAntiAlias = true;
    final gradient = style.gradient;
    if (gradient != null) {
      fgPaint.shader = gradient.createShader(contentRect);
    } else {
      fgPaint.color = style.color;
    }
    canvas.drawPath(path, fgPaint);

    // Logo:先画底衬遮住下方区域,再绘制图片。
    if (activeLogo != null && logoImage != null && logoRect != null && backdropRect != null) {
      final backdropColor = activeLogo.backgroundColor ?? style.backgroundColor;
      if (backdropColor.a > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(backdropRect, Radius.circular(activeLogo.borderRadius)),
          Paint()..color = backdropColor,
        );
      }
      final image = logoImage!;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        logoRect,
        Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.medium,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QrPainter oldDelegate) =>
      oldDelegate.matrix != matrix ||
      oldDelegate.style != style ||
      oldDelegate.logo != logo ||
      oldDelegate.logoImage != logoImage;
}
