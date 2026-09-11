## 2.0.0

### Breaking Changes ⚠️

* **Dependency Migration**: Replaced legacy Flutter package imports with `material_ui` and `cupertino_ui` following the Flutter 3.47 package decoupling.
* **SDK Constraints**: Bumped minimum Flutter SDK requirement to `>=3.47.0`.

### Features & Improvements

* **Example App**: Updated the example application code and import paths to align with the new dependencies.
* **Linter & Analysis**: Added build directory exclusions (`build/**`) in `analysis_options.yaml` to optimize static analysis performance.



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
