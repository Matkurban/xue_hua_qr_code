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
- **Center logo** — `ImageProvider` based, sized as a fraction of the QR code, identical in widget and export
- **Automatic mask selection** — the best of 8 mask patterns is chosen per ISO/IEC 18004 penalty rules
- **Robust error handling** — empty / oversized content falls back to `errorBuilder`; a failing logo (e.g. network error) degrades to a plain, still-scannable QR code
- **Export** — `XueHuaQrCode.toImage()` and `XueHuaQrCode.toPngBytes()` share the exact painter used on screen

## Installation

```yaml
dependencies:
  xue_hua_qr_code: ^1.0.0
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
    scale: 0.22,      // fraction of the QR side, max 0.35
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

### Export

```dart
// PNG bytes — save to a file or show with Image.memory.
final bytes = await XueHuaQrCode.toPngBytes(
  'https://example.com',
  size: 512,
  style: const QrStyle(shape: QrModuleShape.circle),
);

// dart:ui Image.
final image = await XueHuaQrCode.toImage('https://example.com', size: 512);
```

## API reference

### `XueHuaQrCode`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `String` | required | Content to encode |
| `size` | `double?` | `null` | Fixed side length; `null` adapts to parent constraints |
| `style` | `QrStyle` | `QrStyle()` | Visual style |
| `logo` | `QrLogo?` | `null` | Center logo |
| `errorCorrectionLevel` | `QrErrorLevel?` | auto | `medium` normally, `high` when a logo is set |
| `errorBuilder` | `ImageErrorWidgetBuilder?` | `null` | Fallback UI when encoding fails |
| `semanticsLabel` | `String?` | `'QR code'` | Accessibility label |

### `QrStyle`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `shape` | `QrModuleShape` | `square` | `square` / `circle` / `roundedSquare` |
| `color` | `Color` | black | Foreground color (ignored when `gradient` is set) |
| `backgroundColor` | `Color` | white | Background; pass `Colors.transparent` explicitly if needed |
| `gradient` | `Gradient?` | `null` | Foreground gradient (any Flutter `Gradient`) |
| `moduleRadius` | `double?` | per shape | Corner radius as a fraction of module size, 0~0.5 |
| `moduleGap` | `double?` | per shape | Gap between modules as a fraction of module size, 0~0.5 |
| `padding` | `EdgeInsets` | `EdgeInsets.all(8)` | Quiet zone around the code |

### `QrLogo`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image` | `ImageProvider` | required | Logo image |
| `scale` | `double` | `0.2` | Logo side as a fraction of the QR side, max 0.35 |
| `padding` | `double` | `4` | Backdrop padding around the logo (logical px) |
| `backgroundColor` | `Color?` | style background | Backdrop color |
| `borderRadius` | `double` | `0` | Backdrop corner radius (logical px) |

### `QrErrorLevel`

`low` (~7%), `medium` (~15%), `quartile` (~25%), `high` (~30%) — the approximate share of data that can be recovered.

### Export

| Method | Returns | Description |
|--------|---------|-------------|
| `XueHuaQrCode.toImage(value, {size, style, logo, errorCorrectionLevel})` | `Future<ui.Image>` | Render to a `dart:ui` image |
| `XueHuaQrCode.toPngBytes(value, {size, style, logo, errorCorrectionLevel})` | `Future<Uint8List>` | Render to PNG bytes |

Both use the same painter as the widget — what you see is what you export.

## Example app

```bash
cd example
flutter run
```

Five tabs demonstrate basic, circle, rounded, gradient, and logo styles, plus PNG export.

## License

MIT — encoding internals ported from [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin).
