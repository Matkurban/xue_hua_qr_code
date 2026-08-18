/// Thrown when payload exceeds the chosen QR version capacity.
/// 当载荷超过所选 QR 版本容量时抛出。
///
/// Use [QrCodeConfig.informationDensity] `null` or `0` for auto-selection,
/// or set [QrCodeConfig.strictTypeNumber] to `false` to auto-upgrade.
/// 使用 [QrCodeConfig.informationDensity] 为 `null` 或 `0` 自动选版本，
/// 或将 [QrCodeConfig.strictTypeNumber] 设为 `false` 以自动升级版本。
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
