---
name: xue-hua-qr-code-widget
description: >-
  Render, size, and export Flutter QR codes with XueHuaQrCode. Use when adding
  a QR widget, choosing QrErrorLevel, handling empty or oversized payload
  errors, calling toImage or toPngBytes, or wiring errorBuilder.
---

# XueHuaQrCode widget and export

Import only `package:xue_hua_qr_code/xue_hua_qr_code.dart`. Do not invent
`QrCodeConfig`, `MaskPattern`, or `renderQrImage` — those are not public.

Constructor parameters, defaults, throws, and export signatures: [widget-api.md](references/widget-api.md).
Styling and logos: skill `xue-hua-qr-code-styling`. Custom `QrMatrix` / `QrPainter`: skill `xue-hua-qr-code-painter`.

## Guidelines

* Pass `value` as the only required argument. `const XueHuaQrCode(value: '...')` is valid when `style`/`logo` are omitted or const.
* Omit `errorCorrectionLevel` unless the caller asked to override it. Effective level is `medium` without a logo and `high` with a logo.
* Give the widget a bounded shortest side (`size`, or a parent with a finite width or height). Unbounded both axes render `SizedBox.shrink()`.
* Put `errorBuilder` on user-supplied `value`. Empty strings and payloads past QR version 40 capacity never throw from the widget; they use `errorBuilder`, or a debug placeholder / release blank if it is omitted.
* Catch encoding failures on `toImage` / `toPngBytes`. Those APIs rethrow `ArgumentError` (empty `value`) and `InsufficientInformationDensityException` (over capacity). A failed logo load does not throw; the export is a full QR without a logo.
* Use `XueHuaQrCode.toPngBytes` / `toImage` for files and `Image.memory`. Do not reach for unpublished helpers in `lib/src/export.dart`.
* Keep `toImage`/`toPngBytes` `size` positive. Default output side is `512` pixels, independent of the on-screen `size`.

## Examples

### On-screen QR

```dart
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

// Adapts to the parent's shortest finite side.
XueHuaQrCode(value: 'https://example.com')

// Fixed logical side length.
XueHuaQrCode(value: 'https://example.com', size: 240)
```

### User input and encoding failures

```dart
XueHuaQrCode(
  value: userInput,
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
)
```

`error` is the thrown object (`ArgumentError`, `InsufficientInformationDensityException`, or another encode failure).

### PNG export

```dart
try {
  final bytes = await XueHuaQrCode.toPngBytes(
    'https://example.com',
    size: 512,
  );
  // Save bytes, or Image.memory(bytes).
} on ArgumentError catch (error) {
  // Empty value.
} on InsufficientInformationDensityException catch (error) {
  // Payload larger than version-40 capacity at the chosen error level.
}
```

`toImage` takes the same named arguments and returns `Future<ui.Image>`. Dispose that image when finished if you do not hand it to Flutter's image cache.

## Read before writing signatures

Every public member of `XueHuaQrCode`, `QrErrorLevel`, and `InsufficientInformationDensityException` is listed in [widget-api.md](references/widget-api.md). Match those signatures; do not copy stale README defaults.
