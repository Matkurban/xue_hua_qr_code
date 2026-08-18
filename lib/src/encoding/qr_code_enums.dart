/// QR 纠错等级,对应 ISO/IEC 18004 的 L / M / Q / H 四级。
/// 等级越高,可恢复的数据比例越大,但同样内容需要更大的二维码。
enum QrErrorLevel {
  /// L 级,约可恢复 7% 数据。
  low(1, 21),

  /// M 级,约可恢复 15% 数据(无 Logo 时的默认值)。
  medium(0, 25),

  /// Q 级,约可恢复 25% 数据。
  quartile(3, 30),

  /// H 级,约可恢复 30% 数据(带 Logo 时自动使用)。
  high(2, 34);

  const QrErrorLevel(this.value, this.maxTypeNum);

  /// 格式信息位中使用的 BCH 编码值。
  final int value;

  /// 自动选择版本时的搜索上界。
  final int maxTypeNum;
}

/// 应用于 QR 矩阵的掩码模式(8 种)。
/// 公开 API 不暴露该枚举;编码时按 ISO 罚分规则自动选择最优掩码。
enum MaskPattern {
  /// Mask 0: (i + j) % 2 == 0.
  pattern000,

  /// Mask 1: i % 2 == 0.
  pattern001,

  /// Mask 2: j % 3 == 0.
  pattern010,

  /// Mask 3: (i + j) % 3 == 0.
  pattern011,

  /// Mask 4: (i/2 + j/3) % 2 == 0.
  pattern100,

  /// Mask 5: (i*j) % 2 + (i*j) % 3 == 0.
  pattern101,

  /// Mask 6: ((i*j) % 2 + (i*j) % 3) % 2 == 0.
  pattern110,

  /// Mask 7: ((i*j) % 3 + (i + j) % 2) % 2 == 0.
  pattern111,
}

/// QR 数据段的编码模式。
enum QrCodeDataType {
  /// 数字模式(0–9)。
  numbers(1 << 0),

  /// 大写字母数字模式(0–9、A–Z、空格、$%*+-./:)。
  upperAlphaNum(1 << 1),

  /// 8 位字节模式(任意文本的默认模式)。
  defaultType(1 << 2);

  const QrCodeDataType(this.value);

  /// 4 位模式指示值。
  final int value;
}
