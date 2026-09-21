---
name: xue-hua-qr-code-painter
description: >-
  Encode QR payloads with QrMatrix and paint them with QrPainter. Use when
  CustomPaint, custom canvases, isDark/finder/alignment queries, or advanced
  painting beyond the XueHuaQrCode widget.
---

# QrMatrix and QrPainter

For the widget and `toImage`/`toPngBytes`, use skill `xue-hua-qr-code-widget`.
This skill is the encoding matrix and the shared `CustomPainter`.

Import `package:xue_hua_qr_code/xue_hua_qr_code.dart`. Member-level API: [matrix-painter-api.md](references/matrix-painter-api.md).

## Guidelines

* Create matrices with `QrMatrix.encode`. There is no public generative constructor.
* Catch `ArgumentError` (empty `value`) and `InsufficientInformationDensityException` (over version-40 capacity) at the call site. The widget catches these; raw `encode` does not.
* Pass the same `QrErrorLevel` you would use on the widget. Default for `encode` is `QrErrorLevel.medium` (not logo-aware — there is no logo parameter on `encode`).
* Query modules with `isDark(row, col)` using `0 <= row/col < moduleCount`. Finder squares are 7×7 at `finderOrigins`; alignment patterns are 5×5 around `alignmentCenters`.
* Treat `==` as payload identity: two matrices compare equal when `value` and `errorLevel` match, even if you only look at `version`.
* Paint with `QrPainter(matrix: ..., style: ..., logo: ..., logoImage: ...)`. Pass `logoImage` only after the `ImageProvider` has resolved. Null `logoImage` draws a full QR with no center hole.
* Call `painter.paint(canvas, size)` for off-screen canvases, or put the painter on `CustomPaint`. `shouldRepaint` is true when `matrix`, `style`, `logo`, or `logoImage` change.
* Leave mask selection to the library (ISO/IEC 18004 penalty over all 8 masks). `MaskPattern` is not exported.

## Examples

### Encode and inspect

```dart
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

final matrix = QrMatrix.encode(
  'https://example.com',
  errorLevel: QrErrorLevel.medium,
);

final dark = matrix.isDark(0, 0);
final inFinder = matrix.isInFinderPattern(0, 0);
```

### CustomPaint

```dart
CustomPaint(
  size: const Size.square(240),
  isComplex: true,
  painter: QrPainter(
    matrix: matrix,
    style: const QrStyle(shape: QrModuleShape.roundedSquare),
  ),
)
```

Resolve a logo `ui.Image` yourself if you need one; pass it as `logoImage` together with `logo`. Until it is ready, omit `logoImage` so the code stays scannable.

## Read before writing signatures

Every public member of `QrMatrix` and `QrPainter` is listed in [matrix-painter-api.md](references/matrix-painter-api.md).
