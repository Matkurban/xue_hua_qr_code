import 'dart:typed_data';

import '../encoding/mask_evaluation.dart';
import '../encoding/qr_code_enums.dart';
import '../encoding/qr_code_processor.dart';
import '../encoding/qr_code_raw_data.dart';
import '../encoding/qr_util.dart';

/// 不可变的 QR 编码结果:深色模块位图与功能图案几何信息。
///
/// 通过 [QrMatrix.encode] 创建。编码时自动选择最小可用版本,
/// 并按 ISO/IEC 18004 罚分规则在 8 种掩码中选取最优。
class QrMatrix {
  QrMatrix._(
    this._darkBits, {
    required this.value,
    required this.errorLevel,
    required this.version,
    required this.moduleCount,
    required this.alignmentCenters,
  });

  /// 编码的原始内容。
  final String value;

  /// 使用的纠错等级。
  final QrErrorLevel errorLevel;

  /// QR 版本号(1–40)。
  final int version;

  /// 每边模块数(version * 4 + 17)。
  final int moduleCount;

  /// 对齐图案中心坐标列表,元素为 (row, col)。
  final List<(int, int)> alignmentCenters;

  // 按位存储的深色模块,索引 row * moduleCount + col。
  final Uint8List _darkBits;

  /// 定位图案(7x7)左上角坐标,依次为左上、右上、左下。
  List<(int, int)> get finderOrigins => [(0, 0), (0, moduleCount - 7), (moduleCount - 7, 0)];

  /// 编码 [value] 并返回最优掩码下的矩阵。
  ///
  /// [value] 为空或超出版本 40 容量时抛出 [ArgumentError] /
  /// InsufficientInformationDensityException,由上层组件降级处理。
  factory QrMatrix.encode(String value, {QrErrorLevel errorLevel = QrErrorLevel.medium}) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'QR content must not be empty / 内容不能为空');
    }

    final processor = QrCodeProcessor(value, errorLevel: errorLevel);
    final version = QrCodeProcessor.minTypeForData(value, errorLevel, processor.dataType);

    // 对 8 种掩码分别编码并评分,选取罚分最低者。
    QrCodeRawData? bestModules;
    var bestScore = -1;
    for (final mask in MaskPattern.values) {
      final candidate = processor.encode(type: version, maskPattern: mask);
      final score = maskPenaltyScore(candidate);
      if (bestScore < 0 || score < bestScore) {
        bestScore = score;
        bestModules = candidate;
      }
    }

    final modules = bestModules!;
    final moduleCount = modules.length;
    final darkBits = Uint8List((moduleCount * moduleCount + 7) >> 3);
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (modules[row][col].dark) {
          final index = row * moduleCount + col;
          darkBits[index >> 3] |= 1 << (index & 7);
        }
      }
    }

    return QrMatrix._(
      darkBits,
      value: value,
      errorLevel: errorLevel,
      version: version,
      moduleCount: moduleCount,
      alignmentCenters: _computeAlignmentCenters(version, moduleCount),
    );
  }

  /// 计算对齐图案中心,跳过与三个定位图案重叠的位置。
  static List<(int, int)> _computeAlignmentCenters(int version, int moduleCount) {
    final positions = QrUtil.getPatternPosition(version);
    final centers = <(int, int)>[];
    for (final row in positions) {
      for (final col in positions) {
        final overlapsFinder =
            (row <= 7 && col <= 7) ||
            (row <= 7 && col >= moduleCount - 8) ||
            (row >= moduleCount - 8 && col <= 7);
        if (!overlapsFinder) {
          centers.add((row, col));
        }
      }
    }
    return centers;
  }

  /// 指定模块是否为深色。
  bool isDark(int row, int col) {
    final index = row * moduleCount + col;
    return (_darkBits[index >> 3] >> (index & 7)) & 1 == 1;
  }

  /// 指定模块是否属于某个定位图案(7x7 区域)。
  bool isInFinderPattern(int row, int col) {
    final last = moduleCount - 7;
    return (row < 7 && col < 7) || (row < 7 && col >= last) || (row >= last && col < 7);
  }

  /// 指定模块是否属于某个对齐图案(5x5 区域)。
  bool isInAlignmentPattern(int row, int col) {
    for (final (centerRow, centerCol) in alignmentCenters) {
      if ((row - centerRow).abs() <= 2 && (col - centerCol).abs() <= 2) {
        return true;
      }
    }
    return false;
  }

  /// 相同内容与纠错等级视为相等(编码结果确定)。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrMatrix && value == other.value && errorLevel == other.errorLevel;

  @override
  int get hashCode => Object.hash(value, errorLevel);

  @override
  String toString() =>
      'QrMatrix(version=$version, moduleCount=$moduleCount, errorLevel=$errorLevel)';
}
