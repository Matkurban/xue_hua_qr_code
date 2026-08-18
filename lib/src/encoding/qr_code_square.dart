/// QR 符号中模块的功能角色。
enum QrCodeSquareType {
  /// 定位图案模块。
  positionProbe,

  /// 对齐图案模块。
  positionAdjust,

  /// 时序图案模块。
  timingPattern,

  /// 数据或格式模块。
  defaultType,
}

/// 用于区分功能图案位置的区域标记。
enum QrCodeRegion {
  topLeftCorner,
  topRightCorner,
  topMid,
  leftMid,
  rightMid,
  center,
  bottomLeftCorner,
  bottomRightCorner,
  bottomMid,
  margin,
  unknown,
}

/// 附在 [QrCodeSquare] 模块上的元数据。
class QrCodeSquareInfo {
  const QrCodeSquareInfo(this.type, this.region);

  final QrCodeSquareType type;
  final QrCodeRegion region;
}

/// 编码过程中的单个 QR 模块(深/浅)。
/// 仅在编码阶段内部使用;编码结果对外以不可变的 QrMatrix 呈现。
class QrCodeSquare {
  QrCodeSquare({
    required this.dark,
    required this.row,
    required this.col,
    required this.moduleSize,
    this.squareInfo = const QrCodeSquareInfo(QrCodeSquareType.defaultType, QrCodeRegion.unknown),
    this.rowSize = 1,
    this.colSize = 1,
    this.parent,
  });

  /// 是否为深色模块(编码期间由掩码写入,故可变)。
  bool dark;
  final int row;
  final int col;
  final int moduleSize;
  final QrCodeSquareInfo squareInfo;
  final int rowSize;
  final int colSize;
  final QrCodeSquare? parent;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QrCodeSquare &&
        row == other.row &&
        col == other.col &&
        rowSize == other.rowSize &&
        colSize == other.colSize;
  }

  @override
  int get hashCode => Object.hash(row, col, rowSize, colSize);
}
