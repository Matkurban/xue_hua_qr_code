import 'qr_code_enums.dart';
import 'qr_code_square.dart';
import 'qr_util.dart';

/// Places finder patterns, timing, format info, and mask on the module grid.
/// 在模块网格上放置定位图案、时序、格式信息与掩码。
class QrCodeSetup {
  QrCodeSetup._();

  static const int _defaultProbeSize = 7;

  static void setupTopLeftPositionProbePattern(
    List<List<QrCodeSquare?>> modules, [
    int probeSize = _defaultProbeSize,
  ]) {
    setupPositionProbePattern(0, 0, modules, probeSize);
  }

  static void setupTopRightPositionProbePattern(
    List<List<QrCodeSquare?>> modules, [
    int probeSize = _defaultProbeSize,
  ]) {
    setupPositionProbePattern(modules.length - probeSize, 0, modules, probeSize);
  }

  static void setupBottomLeftPositionProbePattern(
    List<List<QrCodeSquare?>> modules, [
    int probeSize = _defaultProbeSize,
  ]) {
    setupPositionProbePattern(0, modules.length - probeSize, modules, probeSize);
  }

  static void setupPositionProbePattern(
    int rowOffset,
    int colOffset,
    List<List<QrCodeSquare?>> modules, [
    int probeSize = _defaultProbeSize,
  ]) {
    final modulesSize = modules.length;

    final squareData = QrCodeSquare(
      dark: false,
      row: rowOffset,
      col: colOffset,
      rowSize: probeSize,
      colSize: probeSize,
      squareInfo: const QrCodeSquareInfo(QrCodeSquareType.positionProbe, QrCodeRegion.unknown),
      moduleSize: modulesSize,
    );

    for (var row = -1; row <= probeSize; row++) {
      for (var col = -1; col <= probeSize; col++) {
        if (!_isInsideModules(row, rowOffset, col, colOffset, modulesSize)) {
          continue;
        }

        final isDark =
            _isTopBottomRowSquare(row, col, probeSize) ||
            _isLeftRightColSquare(row, col, probeSize) ||
            _isMidSquare(row, col, probeSize);

        final region = _findSquareRegion(row, col, probeSize);

        modules[row + rowOffset][col + colOffset] = QrCodeSquare(
          dark: isDark,
          row: row + rowOffset,
          col: col + colOffset,
          squareInfo: QrCodeSquareInfo(QrCodeSquareType.positionProbe, region),
          moduleSize: modulesSize,
          parent: squareData,
        );
      }
    }
  }

  static bool _isInsideModules(int row, int rowOffset, int col, int colOffset, int modulesSize) =>
      row + rowOffset >= 0 &&
      row + rowOffset < modulesSize &&
      col + colOffset >= 0 &&
      col + colOffset < modulesSize;

  static bool _isTopBottomRowSquare(int row, int col, int probeSize) =>
      col >= 0 && col < probeSize && (row == 0 || row == probeSize - 1);

  static bool _isLeftRightColSquare(int row, int col, int probeSize) =>
      row >= 0 && row < probeSize && (col == 0 || col == probeSize - 1);

  static bool _isMidSquare(int row, int col, int probeSize) =>
      row >= 2 && row < probeSize - 2 && col >= 2 && col <= probeSize - 3;

  static QrCodeRegion _findSquareRegion(int row, int col, int probeSize) {
    if (row == 0) {
      if (col == 0) return QrCodeRegion.topLeftCorner;
      if (col == probeSize - 1) return QrCodeRegion.topRightCorner;
      if (col == probeSize) return QrCodeRegion.margin;
      return QrCodeRegion.topMid;
    }
    if (row == probeSize - 1) {
      if (col == 0) return QrCodeRegion.bottomLeftCorner;
      if (col == probeSize - 1) return QrCodeRegion.bottomRightCorner;
      if (col == probeSize) return QrCodeRegion.margin;
      return QrCodeRegion.bottomMid;
    }
    if (row == probeSize) return QrCodeRegion.margin;
    if (col == 0) return QrCodeRegion.leftMid;
    if (col == probeSize - 1) return QrCodeRegion.rightMid;
    if (col == probeSize) return QrCodeRegion.margin;
    return QrCodeRegion.center;
  }

  static void setupPositionAdjustPattern(int type, List<List<QrCodeSquare?>> modules) {
    final pos = QrUtil.getPatternPosition(type);

    for (var i = 0; i < pos.length; i++) {
      for (var j = 0; j < pos.length; j++) {
        final row = pos[i];
        final col = pos[j];

        if (modules[row][col] != null) continue;

        final squareData = QrCodeSquare(
          dark: false,
          row: row - 2,
          col: col - 2,
          rowSize: 6,
          colSize: 6,
          squareInfo: const QrCodeSquareInfo(QrCodeSquareType.positionAdjust, QrCodeRegion.unknown),
          moduleSize: modules.length,
        );

        for (var r = -2; r <= 2; r++) {
          for (var c = -2; c <= 2; c++) {
            modules[row + r][col + c] = QrCodeSquare(
              dark: r == -2 || r == 2 || c == -2 || c == 2 || (r == 0 && c == 0),
              row: row + r,
              col: col + c,
              squareInfo: const QrCodeSquareInfo(
                QrCodeSquareType.positionAdjust,
                QrCodeRegion.unknown,
              ),
              moduleSize: modules.length,
              parent: squareData,
            );
          }
        }
      }
    }
  }

  static void setupTimingPattern(int moduleCount, List<List<QrCodeSquare?>> modules) {
    for (var r = 8; r < moduleCount - 8; r++) {
      if (modules[r][6] != null) continue;
      modules[r][6] = QrCodeSquare(
        dark: r % 2 == 0,
        row: r,
        col: 6,
        squareInfo: const QrCodeSquareInfo(QrCodeSquareType.timingPattern, QrCodeRegion.unknown),
        moduleSize: modules.length,
      );
    }

    for (var c = 8; c < moduleCount - 8; c++) {
      if (modules[6][c] != null) continue;
      modules[6][c] = QrCodeSquare(
        dark: c % 2 == 0,
        row: 6,
        col: c,
        squareInfo: const QrCodeSquareInfo(QrCodeSquareType.timingPattern, QrCodeRegion.unknown),
        moduleSize: modules.length,
      );
    }
  }

  static void setupTypeInfo(
    QrErrorLevel errorLevel,
    MaskPattern maskPattern,
    int moduleCount,
    List<List<QrCodeSquare?>> modules,
  ) {
    final data = errorLevel.value << 3 | maskPattern.index;
    final bits = QrUtil.getBchTypeInfo(data);

    for (var i = 0; i <= 14; i++) {
      final mod = (bits >> i) & 1 == 1;
      if (i < 6) {
        _set(i, 8, mod, modules);
      } else if (i < 8) {
        _set(i + 1, 8, mod, modules);
      } else {
        _set(moduleCount - 15 + i, 8, mod, modules);
      }
    }

    for (var i = 0; i <= 14; i++) {
      final mod = (bits >> i) & 1 == 1;
      if (i < 8) {
        _set(8, moduleCount - i - 1, mod, modules);
      } else if (i < 9) {
        _set(8, 15 - i, mod, modules);
      } else {
        _set(8, 15 - i - 1, mod, modules);
      }
    }

    _set(moduleCount - 8, 8, true, modules);
  }

  static void setupTypeNumber(int type, int moduleCount, List<List<QrCodeSquare?>> modules) {
    final bits = QrUtil.getBchTypeNumber(type);

    for (var i = 0; i <= 17; i++) {
      final mod = (bits >> i) & 1 == 1;
      _set(i ~/ 3, i % 3 + moduleCount - 8 - 3, mod, modules);
    }

    for (var i = 0; i <= 17; i++) {
      final mod = (bits >> i) & 1 == 1;
      _set(i % 3 + moduleCount - 8 - 3, i ~/ 3, mod, modules);
    }
  }

  static void applyMaskPattern(
    List<int> data,
    MaskPattern maskPattern,
    int moduleCount,
    List<List<QrCodeSquare?>> modules,
  ) {
    var inc = -1;
    var bitIndex = 7;
    var byteIndex = 0;
    var row = moduleCount - 1;
    var col = moduleCount - 1;

    while (col > 0) {
      if (col == 6) col--;

      while (true) {
        for (var c = 0; c <= 1; c++) {
          if (modules[row][col - c] == null) {
            var dark = false;

            if (byteIndex < data.length) {
              dark = ((data[byteIndex] >> bitIndex) & 1) == 1;
            }

            final mask = QrUtil.getMask(maskPattern, row, col - c);
            if (mask) dark = !dark;

            _set(row, col - c, dark, modules);

            bitIndex--;
            if (bitIndex == -1) {
              byteIndex++;
              bitIndex = 7;
            }
          }
        }

        row += inc;
        if (row < 0 || moduleCount <= row) {
          row -= inc;
          inc = -inc;
          break;
        }
      }

      col -= 2;
    }
  }

  static void _set(
    int row,
    int col,
    bool value,
    List<List<QrCodeSquare?>> modules, [
    QrCodeSquare? parent,
  ]) {
    final qrCodeSquare = modules[row][col];

    if (qrCodeSquare != null) {
      qrCodeSquare.dark = value;
    } else {
      modules[row][col] = QrCodeSquare(
        dark: value,
        row: row,
        col: col,
        moduleSize: modules.length,
        parent: parent,
      );
    }
  }
}
