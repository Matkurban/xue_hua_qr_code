## 2.0.2

* Ship Agent Skills under `skills/` (`xue-hua-qr-code-widget`, `xue-hua-qr-code-styling`, `xue-hua-qr-code-painter`) for `dart run skills@ get`.
* Document every public constructor, field, getter, and method in skill `references/` and align `README.md` / `README_zh.md` with the source (semantics label default, export `size` / throws, per-shape module defaults, `QrMatrix`, `QrPainter`, `InsufficientInformationDensityException`).
* Fix leftover `QrCodeConfig` dartdoc on `InsufficientInformationDensityException`.

## 2.0.1

* fix bugs

## 2.0.0

* **SDK Constraints**: Bumped minimum Flutter SDK requirement to `>=3.10.0`,Dart minium SDK to `>=3.0.0`.

## 1.0.0

Initial release.

* `XueHuaQrCode(value: ...)` widget — one required parameter renders a standard, scannable QR code that adapts to parent constraints
* `QrStyle` — module shape (square / circle / rounded), colors, `Gradient` support, proportional `moduleRadius` / `moduleGap`, quiet-zone `padding`
* `QrLogo` — center logo sized as a fraction of the QR side, with backdrop padding / color / radius; identical proportions in widget and export
* `QrErrorLevel` — `low` / `medium` / `quartile` / `high` matching ISO L/M/Q/H; automatically raised to `high` when a logo is present
* Automatic mask selection among all 8 patterns using ISO/IEC 18004 penalty scoring
* Robust error handling — empty / oversized content falls back to `errorBuilder`; a failing logo degrades to a plain, still-scannable QR code
* Export via `XueHuaQrCode.toImage()` and `XueHuaQrCode.toPngBytes()`, sharing the exact on-screen painter
* Immutable `QrMatrix` encoding model and stateless `QrPainter` for advanced custom painting
* Pure Dart implementation — no native dependencies, no platform channels; encoding internals ported from qrcode-kotlin
