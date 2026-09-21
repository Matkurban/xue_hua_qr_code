# Public API: QrMatrix, QrPainter

Source of truth: `lib/src/model/qr_matrix.dart`, `lib/src/painting/qr_painter.dart`. Barrel: `package:xue_hua_qr_code/xue_hua_qr_code.dart`.

## `class QrMatrix`

Immutable encode result: packed dark-module bitmap plus finder/alignment geometry.

Version is the smallest that fits the payload at `errorLevel` (QR versions 1–40). Among 8 masks, the lowest ISO/IEC 18004 penalty score wins. `moduleCount` is `version * 4 + 17`.

The generative constructor is private (`QrMatrix._`).

### `factory QrMatrix.encode`

```dart
factory QrMatrix.encode(
  String value, {
  QrErrorLevel errorLevel = QrErrorLevel.medium,
})
```

**Throws**

- `ArgumentError.value(value, 'value', 'QR content must not be empty / 内容不能为空')` when `value.isEmpty`.
- `InsufficientInformationDensityException` when the bitstream does not fit version 40 at `errorLevel`.

This API is **not** logo-aware. Callers that overlay a logo should pass `QrErrorLevel.high` themselves (the widget/`toImage` helpers do that when `logo != null`).

### Instance fields

| Member | Type | Notes |
| --- | --- | --- |
| `value` | `String` | Original payload. |
| `errorLevel` | `QrErrorLevel` | Level used for this encode. |
| `version` | `int` | QR version `1..40`. |
| `moduleCount` | `int` | Modules per side (`version * 4 + 17`). |
| `alignmentCenters` | `List<(int, int)>` | Alignment-pattern centers `(row, col)`, excluding positions that overlap the three finders. Version 1 has none. |

Dark bits are private (`Uint8List _darkBits`).

### `List<(int, int)> get finderOrigins`

```dart
[(0, 0), (0, moduleCount - 7), (moduleCount - 7, 0)]
```

Top-left corners of the three 7×7 finder patterns: top-left, top-right, bottom-left. There is no bottom-right finder.

### `bool isDark(int row, int col)`

`true` if the module at `(row, col)` is dark. Index is `row * moduleCount + col` into the packed bitmap.

Callers must keep `row`/`col` in `0 .. moduleCount-1`. Out-of-range indexes are not validated and can throw or read adjacent bits.

### `bool isInFinderPattern(int row, int col)`

`true` if the module lies in any 7×7 finder (including light modules inside those squares):

```dart
final last = moduleCount - 7;
(row < 7 && col < 7) ||
(row < 7 && col >= last) ||
(row >= last && col < 7)
```

### `bool isInAlignmentPattern(int row, int col)`

`true` if the module is within Chebyshev distance `2` of any `alignmentCenters` entry (the 5×5 alignment pattern).

### `@override bool operator ==(Object other)`

```dart
identical(this, other) ||
other is QrMatrix && value == other.value && errorLevel == other.errorLevel
```

`version` / `moduleCount` / bits are not compared; they are determined by `value` + `errorLevel`.

### `@override int get hashCode`

```dart
Object.hash(value, errorLevel)
```

### `@override String toString()`

```dart
'QrMatrix(version=$version, moduleCount=$moduleCount, errorLevel=$errorLevel)'
```

(`value` is not included.)

## `class QrPainter extends CustomPainter`

Stateless painter shared by `XueHuaQrCode` and `toImage`/`toPngBytes`. Geometry is computed in doubles from the available `Size` so the content square fills the inner area after padding.

### Constructor

```dart
const QrPainter({
  required this.matrix,
  this.style = const QrStyle(),
  this.logo,
  this.logoImage,
});
```

| Field | Type | Default | Notes |
| --- | --- | --- | --- |
| `matrix` | `QrMatrix` | required | Encode result. |
| `style` | `QrStyle` | `const QrStyle()` | Colors, shape, padding. |
| `logo` | `QrLogo?` | `null` | Logo layout. Drawn only if `logoImage` is also non-null. |
| `logoImage` | `ui.Image?` | `null` | Decoded logo pixels. `null` → paint the full matrix; **do not** clear the center. |

### `@override void paint(Canvas canvas, Size size)`

No-op when `size.isEmpty`.

Order:

1. Fill `Offset.zero & size` with `style.backgroundColor` if that color's alpha `> 0`.
2. Deflate by `style.padding`. No-op if the inner rect is empty. Content is a square of side `inner.shortestSide` centered in the inner rect.
3. Module cell size = `contentSide / matrix.moduleCount`.
4. If both `logo` and `logoImage` are non-null, compute a centered square `logoRect` of side `contentSide * logo.scale` and `backdropRect = logoRect.inflate(logo.padding)`.
5. Build one `Path` with `PathFillType.evenOdd`:
   - Finders: for each `finderOrigins`, add 7×7, 5×5, 3×3 rounded rects (even-odd ring + eye).
   - Alignments: for each center, skip if the 5×5 origin overlaps `backdropRect`; else add 5×5, 3×3, 1×1 rounded rects.
   - Data (and timing/format) modules: skip light modules, finder cells, alignment cells, and any cell whose deflated rect overlaps `backdropRect`. Then:
     - `square`: `addRect` if `effectiveModuleRadius <= 0`, else rounded rect.
     - `circle`: `addOval`.
     - `roundedSquare`: rounded rect with `effectiveModuleRadius`.
6. Fill the path with `style.gradient` shader on `contentRect`, or `style.color`.
7. If logo is active: fill `backdropRect` as `RRect` with `logo.backgroundColor ?? style.backgroundColor` when that color's alpha `> 0`; then `drawImageRect` the full `logoImage` into `logoRect` (`FilterQuality.medium`).

Finder/alignment rounded-corner ratio is `style.effectiveModuleRadius` times the **pattern rect's** shortest side. Data-module gap is `cell * effectiveModuleGap / 2` inset.

### `@override bool shouldRepaint(covariant QrPainter oldDelegate)`

```dart
oldDelegate.matrix != matrix ||
oldDelegate.style != style ||
oldDelegate.logo != logo ||
oldDelegate.logoImage != logoImage
```

Uses `QrMatrix.==` and `QrStyle.==` / `QrLogo.==`.

No other `CustomPainter` methods are overridden (`hitTest`, `semanticsBuilder`, `shouldRebuildSemantics` stay at `CustomPainter` defaults).
