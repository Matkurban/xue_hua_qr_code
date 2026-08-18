import 'qr_code_raw_data.dart';

/// 按 ISO/IEC 18004 的四条罚分规则对已掩码的矩阵评分,分数越低可扫性越好。
int maskPenaltyScore(QrCodeRawData modules) {
  final n = modules.length;
  var penalty = 0;

  bool dark(int row, int col) => modules[row][col].dark;

  // 规则 1:行/列中连续 5 个及以上同色模块,罚 3 + (长度 - 5)。
  for (var isRow = 0; isRow < 2; isRow++) {
    for (var i = 0; i < n; i++) {
      var runLength = 1;
      var previous = isRow == 0 ? dark(i, 0) : dark(0, i);
      for (var j = 1; j < n; j++) {
        final current = isRow == 0 ? dark(i, j) : dark(j, i);
        if (current == previous) {
          runLength++;
        } else {
          if (runLength >= 5) penalty += 3 + (runLength - 5);
          runLength = 1;
          previous = current;
        }
      }
      if (runLength >= 5) penalty += 3 + (runLength - 5);
    }
  }

  // 规则 2:2x2 同色区块,每个罚 3。
  for (var row = 0; row < n - 1; row++) {
    for (var col = 0; col < n - 1; col++) {
      final value = dark(row, col);
      if (value == dark(row, col + 1) &&
          value == dark(row + 1, col) &&
          value == dark(row + 1, col + 1)) {
        penalty += 3;
      }
    }
  }

  // 规则 3:出现 1011101 且一侧紧邻 0000(类定位图案),每处罚 40。
  const patternA = [true, false, true, true, true, false, true, false, false, false, false];
  const patternB = [false, false, false, false, true, false, true, true, true, false, true];
  for (var isRow = 0; isRow < 2; isRow++) {
    for (var i = 0; i < n; i++) {
      for (var j = 0; j <= n - patternA.length; j++) {
        var matchesA = true;
        var matchesB = true;
        for (var k = 0; k < patternA.length; k++) {
          final current = isRow == 0 ? dark(i, j + k) : dark(j + k, i);
          if (current != patternA[k]) matchesA = false;
          if (current != patternB[k]) matchesB = false;
          if (!matchesA && !matchesB) break;
        }
        if (matchesA || matchesB) penalty += 40;
      }
    }
  }

  // 规则 4:深色模块占比偏离 50%,每 5% 罚 10。
  var darkCount = 0;
  for (var row = 0; row < n; row++) {
    for (var col = 0; col < n; col++) {
      if (dark(row, col)) darkCount++;
    }
  }
  final deviation = (darkCount * 100 ~/ (n * n) - 50).abs();
  penalty += (deviation ~/ 5) * 10;

  return penalty;
}
