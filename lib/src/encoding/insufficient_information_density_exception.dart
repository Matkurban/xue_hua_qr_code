/// Thrown when the payload exceeds QR version 40 capacity at the chosen error level.
/// 当载荷在所选纠错等级下超过 QR 版本 40 容量时抛出。
///
/// [QrMatrix.encode] always picks the smallest fitting version automatically.
/// This exception means even version 40 cannot hold [QrMatrix.value].
/// Shorten the payload, or use a lower [QrErrorLevel] (less correction, more capacity).
/// [QrMatrix.encode] 始终自动选择能容纳数据的最小版本。
/// 抛出本异常表示即使版本 40 也无法容纳 [QrMatrix.value]。
/// 请缩短内容，或改用更低的 [QrErrorLevel]（纠错更少、容量更大）。
class InsufficientInformationDensityException implements Exception {
  /// Creates an exception with an optional detail [message].
  /// 创建异常，可选详情 [message]。
  InsufficientInformationDensityException([this.message]);

  /// Human-readable detail including needed vs maximum bits.
  /// 人类可读的详情（含所需与最大 bit 数）。
  final String? message;

  @override
  String toString() => 'InsufficientInformationDensityException: ${message ?? ''}';
}
