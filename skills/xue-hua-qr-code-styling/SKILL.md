---
name: xue-hua-qr-code-styling
description: >-
  Style XueHuaQrCode with QrStyle, QrModuleShape, and QrLogo. Use when setting
  module shape, colors, Gradient, moduleRadius, moduleGap, quiet-zone padding,
  or a center logo image.
---

# QrStyle, QrModuleShape, and QrLogo

Import `package:xue_hua_qr_code/xue_hua_qr_code.dart`. Full signatures, asserts, and equality: [style-api.md](references/style-api.md).

## Guidelines

* Start from `const QrStyle()`. That is opaque black modules on white with 8 px quiet zone and square modules.
* Set `backgroundColor: Colors.transparent` when a transparent backdrop is required. The default is `Color(0xFFFFFFFF)`, not theme-dependent, so dark app themes still scan.
* Put a `Gradient` on `QrStyle.gradient` to paint all dark modules in one shader. `color` is ignored while `gradient` is non-null.
* Treat `moduleRadius` and `moduleGap` as **fractions of one module** in `0..0.5`, or omit them so the shape supplies defaults: square `0.0/0.0`, circle `0.5/0.1`, roundedSquare `0.3/0.1`.
* Size a logo with `QrLogo.scale` (fraction of the QR **content** side, exclusive of quiet zone). Allowed range is `(0, 0.35]`. Default `0.2`.
* Omit `errorCorrectionLevel` when a logo is present unless an override is requested; the widget/export raise it to `high`.
* Use `AssetImage`, `NetworkImage`, `MemoryImage`, or any `ImageProvider`. A failed load must leave a complete QR — never empty the center yourself.
* `QrStyle.copyWith` cannot clear `gradient` back to `null` (`??` keeps the old value). Build a new `QrStyle(...)` to drop a gradient.
* `padding` is `EdgeInsets` in logical pixels (quiet zone) and applies to both the widget and export.

## Examples

### Shapes, radius, gap, gradient

```dart
import 'package:flutter/material.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(
    shape: QrModuleShape.roundedSquare,
    moduleRadius: 0.4,
    moduleGap: 0.15,
    gradient: LinearGradient(colors: [Colors.pink, Colors.blue]),
    padding: EdgeInsets.all(12),
  ),
)
```

### Center logo

```dart
XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(shape: QrModuleShape.roundedSquare),
  logo: const QrLogo(
    image: AssetImage('assets/logo.png'),
    scale: 0.22,
    padding: 6,
    borderRadius: 8,
  ),
)
```

`QrLogo.backgroundColor` omitted → the logo backdrop uses `style.backgroundColor`. Modules under the inflated logo backdrop are skipped so they do not show through.

## Read before writing signatures

Every public member of `QrModuleShape`, `QrStyle`, and `QrLogo` is listed in [style-api.md](references/style-api.md).
