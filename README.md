**Languages:** [English](README.md) | [中文](README_zh.md)

# xue_hua_qr_code

Out-of-the-box QR code widget for Flutter. Pure Dart — no native dependencies, no platform channels.

```dart
XueHuaQrCode(value: 'https://example.com')
```

That is all you need: a scannable black-on-white QR code that adapts to its parent constraints.

## Features

- **One required parameter** — pass `value`, get a standard QR code with sensible defaults
- **Styling** — square / circle / rounded modules, colors, gradients, proportional corner radius and gaps
- **Center logo** — `ImageProvider` based, sized as a fraction of the QR content side, identical in widget and export
- **Automatic mask selection** — the best of 8 mask patterns is chosen per ISO/IEC 18004 penalty rules
- **Robust error handling** — empty / oversized content falls back to `errorBuilder` on the widget; a failing logo (e.g. network error) degrades to a plain, still-scannable QR code
- **Export** — `XueHuaQrCode.toImage()` and `XueHuaQrCode.toPngBytes()` share the exact painter used on screen
- **AI agent skills** — official Agent Skills ship in the package for Cursor, Claude Code, and other agents

## Installation

```yaml
dependencies:
  xue_hua_qr_code: ^2.0.2
```

## Basic usage

```dart
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

// Adapts to the parent's shortest bounded side.
XueHuaQrCode(value: 'https://example.com')

// Fixed size.
XueHuaQrCode(value: 'https://example.com', size: 240)
```

## Advanced usage

### Custom style

```dart
XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(
    shape: QrModuleShape.roundedSquare,
    moduleRadius: 0.4,          // fraction of a module, 0~0.5
    moduleGap: 0.15,            // fraction of a module, 0~0.5
    gradient: LinearGradient(colors: [Colors.pink, Colors.blue]),
    padding: EdgeInsets.all(12), // quiet zone
  ),
)
```

### With a logo

```dart
XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(shape: QrModuleShape.roundedSquare),
  logo: const QrLogo(
    image: AssetImage('assets/logo.png'), // NetworkImage / MemoryImage also work
    scale: 0.22,      // fraction of the QR content side, (0, 0.35]
    padding: 6,
    borderRadius: 8,
  ),
  // Error correction is automatically raised to `high` when a logo is present.
)
```

If the logo fails to load (missing asset, network error), the widget renders the full QR code without the logo — it never leaves an unscannable hole.

### Error handling

```dart
XueHuaQrCode(
  value: userInput, // may be empty or too long
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
)
```

The widget catches encoding failures. `toImage` / `toPngBytes` rethrow them (`ArgumentError` for empty `value`, `InsufficientInformationDensityException` when the payload exceeds version 40).

### Export

```dart
// PNG bytes — save to a file or show with Image.memory.
// `size` defaults to 512; encoding failures throw (unlike the widget).
final bytes = await XueHuaQrCode.toPngBytes(
  'https://example.com',
  size: 512,
  style: const QrStyle(shape: QrModuleShape.circle),
);

// dart:ui Image. Dispose the image when you are done with it.
final image = await XueHuaQrCode.toImage('https://example.com', size: 512);
```

## API reference

### `XueHuaQrCode`

| Parameter              | Type                       | Default     | Description                                                                 |
|------------------------|----------------------------|-------------|-----------------------------------------------------------------------------|
| `value`                | `String`                   | required    | Content to encode                                                           |
| `size`                 | `double?`                  | `null`      | Fixed logical side; `null` uses the parent's shortest finite constraint     |
| `style`                | `QrStyle`                  | `QrStyle()` | Visual style                                                                |
| `logo`                 | `QrLogo?`                  | `null`      | Center logo                                                                 |
| `errorCorrectionLevel` | `QrErrorLevel?`            | `null`      | Automatic via `effectiveErrorLevel`: `medium` without a logo, `high` with one |
| `errorBuilder`         | `ImageErrorWidgetBuilder?` | `null`      | Fallback UI when encoding fails; debug placeholder / release blank if omitted |
| `semanticsLabel`       | `String?`                  | `null`      | Accessibility label; `null` is shown as `'QR code'`                         |

`QrErrorLevel get effectiveErrorLevel` — `errorCorrectionLevel` if set, otherwise `high` when `logo != null` and `medium` otherwise.

### `QrStyle`

| Parameter         | Type            | Default             | Description                                                                 |
|-------------------|-----------------|---------------------|-----------------------------------------------------------------------------|
| `shape`           | `QrModuleShape` | `square`            | `square` / `circle` / `roundedSquare`                                       |
| `color`           | `Color`         | `Color(0xFF000000)` | Foreground color (ignored when `gradient` is set)                           |
| `backgroundColor` | `Color`         | `Color(0xFFFFFFFF)` | Background; pass `Colors.transparent` explicitly if needed                  |
| `gradient`        | `Gradient?`     | `null`              | Foreground gradient (any Flutter `Gradient`)                                |
| `moduleRadius`    | `double?`       | per shape           | Corner radius as a fraction of module size, 0~0.5                           |
| `moduleGap`       | `double?`       | per shape           | Gap between modules as a fraction of module size, 0~0.5                     |
| `padding`         | `EdgeInsets`    | `EdgeInsets.all(8)` | Quiet zone around the code (logical px); applied to widget and export       |

When `moduleRadius` / `moduleGap` are `null`, `effectiveModuleRadius` / `effectiveModuleGap` resolve by shape: `square` → `0.0` / `0.0`, `circle` → `0.5` / `0.1`, `roundedSquare` → `0.3` / `0.1`.

`copyWith` uses `??` and cannot clear `gradient` back to `null`; construct a new `QrStyle` to drop a gradient.

### `QrLogo`

| Parameter         | Type            | Default          | Description                                                |
|-------------------|-----------------|------------------|------------------------------------------------------------|
| `image`           | `ImageProvider` | required         | Logo image                                                 |
| `scale`           | `double`        | `0.2`            | Logo side as a fraction of the QR **content** side, `(0, 0.35]` |
| `padding`         | `double`        | `4`              | Backdrop padding around the logo (logical px)              |
| `backgroundColor` | `Color?`        | `null`           | Backdrop color; `null` uses `style.backgroundColor`        |
| `borderRadius`    | `double`        | `0`              | Backdrop corner radius (logical px)                        |

### `QrErrorLevel`

`low` (~7%), `medium` (~15%), `quartile` (~25%), `high` (~30%) — the approximate share of data that can be recovered.

Public fields `value` (format-information BCH: L=1, M=0, Q=3, H=2) and `maxTypeNum` (encoder version-search bound) are for the encoder. Pass the enum names from app code.

### Export

| Method                                                                      | Returns             | Description |
|-----------------------------------------------------------------------------|---------------------|-------------|
| `XueHuaQrCode.toImage(value, {size = 512, style, logo, errorCorrectionLevel})`    | `Future<ui.Image>`  | Render to a `dart:ui` image |
| `XueHuaQrCode.toPngBytes(value, {size = 512, style, logo, errorCorrectionLevel})` | `Future<Uint8List>` | Render to PNG bytes         |

Both use the same painter as the widget. Encoding failures throw; a failed logo load degrades to a full QR without a logo. `size` must be `> 0`. Dispose the `ui.Image` from `toImage` when finished. `toPngBytes` may throw `StateError` if PNG encoding fails.

### `QrMatrix`

Immutable encode result. Create with `QrMatrix.encode(value, {errorLevel = QrErrorLevel.medium})`.

| Member | Type | Description |
| --- | --- | --- |
| `value` | `String` | Encoded payload |
| `errorLevel` | `QrErrorLevel` | Level used for this encode |
| `version` | `int` | QR version 1–40 |
| `moduleCount` | `int` | Modules per side (`version * 4 + 17`) |
| `alignmentCenters` | `List<(int, int)>` | Alignment-pattern centers `(row, col)` |
| `finderOrigins` | `List<(int, int)>` | Top-left corners of the three 7×7 finders |
| `isDark(row, col)` | `bool` | Whether that module is dark |
| `isInFinderPattern(row, col)` | `bool` | Inside a 7×7 finder |
| `isInAlignmentPattern(row, col)` | `bool` | Inside a 5×5 alignment pattern |

Empty `value` throws `ArgumentError`. Over-capacity throws `InsufficientInformationDensityException`. Equality compares `value` and `errorLevel` only.

### `QrPainter`

`CustomPainter` shared by the widget and export.

```dart
const QrPainter({
  required QrMatrix matrix,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  ui.Image? logoImage,
})
```

`paint` / `shouldRepaint` follow `CustomPainter`. A logo is drawn only when both `logo` and `logoImage` are non-null; otherwise the full matrix is painted (no hole).

### `InsufficientInformationDensityException`

Thrown when the payload does not fit QR version 40 at the chosen error level. Optional `message` includes needed vs maximum bits. `toString()` is `InsufficientInformationDensityException: ${message ?? ''}`.

There is no public version override: `QrMatrix.encode` always selects the smallest fitting version.

## AI agent skills

This package ships Agent Skills that teach AI coding assistants the public API. After adding the dependency, install them with:

```bash
dart run skills@ get
```

That scans your dependencies and copies selected skills into your agent's skills directory (for example `.agents/skills/` or `.cursor/skills/`). Re-run after upgrading the package.

| Skill | Use it for |
| --- | --- |
| `xue-hua-qr-code-widget` | `XueHuaQrCode`, `QrErrorLevel`, `errorBuilder`, `toImage` / `toPngBytes` |
| `xue-hua-qr-code-styling` | `QrStyle`, `QrModuleShape`, `QrLogo` |
| `xue-hua-qr-code-painter` | `QrMatrix`, `QrPainter`, custom `CustomPaint` |

Each skill includes a `references/` file with every public constructor, field, getter, and method. Agents that load skills from another directory can copy the folders under `skills/` in this repository.

## Example app

```bash
cd example
flutter run
```

Five tabs demonstrate basic, circle, rounded, gradient, and logo styles, plus PNG export.

## License

MIT — encoding internals ported from [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin).
