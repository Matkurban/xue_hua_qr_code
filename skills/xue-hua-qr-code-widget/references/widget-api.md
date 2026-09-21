# Public API: XueHuaQrCode, QrErrorLevel, InsufficientInformationDensityException

Source of truth: `lib/src/widgets/xue_hua_qr_code.dart`, `lib/src/encoding/qr_code_enums.dart` (`QrErrorLevel` only), `lib/src/encoding/insufficient_information_density_exception.dart`, `lib/src/export.dart` (behavior of the static export methods). Barrel: `package:xue_hua_qr_code/xue_hua_qr_code.dart`.

## `class XueHuaQrCode extends StatefulWidget`

Renders a scannable QR code from `value`. Encoding uses `QrMatrix.encode`. Painting uses `QrPainter` (same painter as export).

### Constructor

```dart
const XueHuaQrCode({
  super.key,
  required this.value,
  this.size,
  this.style = const QrStyle(),
  this.logo,
  this.errorCorrectionLevel,
  this.errorBuilder,
  this.semanticsLabel,
});
```

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `key` | `Key?` | `null` | `Widget` key. |
| `value` | `String` | required | Payload to encode. Empty or over-capacity does not throw from the widget; see `errorBuilder`. |
| `size` | `double?` | `null` | Logical side length in pixels. Non-null → `SizedBox.square(dimension: size)`. `null` → `LayoutBuilder` uses the shortest finite max constraint (width and height both finite → `min`; only one finite → that one; both infinite → `SizedBox.shrink()`). The square is then `Align`ed in non-square tight constraints. |
| `style` | `QrStyle` | `const QrStyle()` | Visual style. See skill `xue-hua-qr-code-styling`. |
| `logo` | `QrLogo?` | `null` | Center logo. Load failure keeps a full, still-scannable QR (no hole). Presence without an explicit `errorCorrectionLevel` raises correction to `high`. |
| `errorCorrectionLevel` | `QrErrorLevel?` | `null` | `null` means automatic via `effectiveErrorLevel`. |
| `errorBuilder` | `ImageErrorWidgetBuilder?` | `null` | `(BuildContext context, Object error, StackTrace? stackTrace) → Widget`. Used when encoding throws. If omitted: debug shows `_QrErrorPlaceholder` (error text on a dark red box); release shows `SizedBox.expand()`. Encode failures are also reported with `FlutterError.reportError` when `errorBuilder` is null. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. `null` is replaced at paint time with `'QR code'`. Wrapped in `Semantics(image: true, textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr)`. |

### Instance fields

All fields are `final`.

- `String value`
- `double? size`
- `QrStyle style`
- `QrLogo? logo`
- `QrErrorLevel? errorCorrectionLevel`
- `ImageErrorWidgetBuilder? errorBuilder`
- `String? semanticsLabel`

### `QrErrorLevel get effectiveErrorLevel`

```dart
errorCorrectionLevel ?? (logo != null ? QrErrorLevel.high : QrErrorLevel.medium)
```

Re-encodes when `value` or `effectiveErrorLevel` changes (`didUpdateWidget`). Style-only changes do not re-encode.

### `static Future<ui.Image> toImage`

```dart
static Future<ui.Image> toImage(
  String value, {
  double size = 512,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  QrErrorLevel? errorCorrectionLevel,
})
```

Renders with the same `QrPainter` as the widget. `size` is the output image side in pixels (`assert(size > 0)`). Pixel dimensions passed to `Picture.toImage` are `size.ceil()`.

Error-level resolution matches the widget: `errorCorrectionLevel ?? (logo != null ? high : medium)`.

**Throws**

- `AssertionError` if `size <= 0` (assert).
- `ArgumentError` if `value` is empty (`QrMatrix.encode`).
- `InsufficientInformationDensityException` if the payload exceeds version-40 capacity at the resolved error level.
- Any other exception from encoding.

Logo resolve failures are caught, reported via `FlutterError.reportError`, and the image is painted without a logo. They do not fail the future.

The caller owns the returned `ui.Image` and should `dispose()` it when done (the PNG helper disposes internally).

### `static Future<Uint8List> toPngBytes`

```dart
static Future<Uint8List> toPngBytes(
  String value, {
  double size = 512,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  QrErrorLevel? errorCorrectionLevel,
})
```

Same arguments and encode/logo behavior as `toImage`, then encodes PNG via `ui.Image.toByteData(format: ImageByteFormat.png)` and disposes the image.

**Throws** everything `toImage` throws, plus `StateError('Failed to encode QR code as PNG')` if `toByteData` returns `null`.

### `State<XueHuaQrCode> createState()`

Standard `StatefulWidget` override. Application code does not call this.

Private state loads the logo with `ImageProvider.resolve(createLocalImageConfiguration(context))` and re-resolves when `logo.image` changes. Logo errors null out the decoded image and report `FlutterError`; the QR stays complete.

## `enum QrErrorLevel`

ISO/IEC 18004 L / M / Q / H. Higher correction recovers more damage and needs a larger symbol for the same payload.

```dart
enum QrErrorLevel {
  low(1, 21),       // L, ~7% recovery
  medium(0, 25),    // M, ~15% recovery; default when no logo
  quartile(3, 30),  // Q, ~25% recovery
  high(2, 34);      // H, ~30% recovery; automatic when a logo is set
}
```

### Enum constructor (not called from app code)

```dart
const QrErrorLevel(this.value, this.maxTypeNum);
```

### `final int value`

BCH value stored in the QR format information bits: `low=1`, `medium=0`, `quartile=3`, `high=2`. Do not confuse with recovery percentage. App code should pass the enum name, not this integer.

### `final int maxTypeNum`

Exclusive upper bound used by the encoder's first pass when searching for the smallest fitting version (`for (typeNum = 1; typeNum < maxTypeNum; ...)`), then version 40 is tried separately. Not an API for choosing QR version from UI code.

`MaskPattern` and `QrCodeDataType` live in the same source file and are **not** exported. Masks are chosen automatically by ISO penalty scoring.

## `class InsufficientInformationDensityException implements Exception`

Thrown by `QrMatrix.encode` (via the encoder) when the payload does not fit QR version 40 at the chosen `QrErrorLevel`.

There is no public `QrCodeConfig`. Version is always auto-selected as the smallest that fits, then this exception means even version 40 is too small. Lowering `QrErrorLevel` (less correction) can increase capacity; shortening `value` always does.

### Constructor

```dart
InsufficientInformationDensityException([this.message]);
```

### `final String? message`

Optional detail. Encoder messages look like:

`Data exceeds maximum QR capacity at version 40 [neededBits=..., maximumBitsForDensityLevel=...].`

### `@override String toString()`

```dart
'InsufficientInformationDensityException: ${message ?? ''}'
```

### Widget vs export

| Path | Empty `value` | Over capacity |
| --- | --- | --- |
| `XueHuaQrCode` widget | Caught; `errorBuilder` / placeholder | Caught; `errorBuilder` / placeholder |
| `toImage` / `toPngBytes` | Rethrown `ArgumentError` | Rethrown `InsufficientInformationDensityException` |
