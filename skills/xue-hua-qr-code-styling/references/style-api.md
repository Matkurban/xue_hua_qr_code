# Public API: QrModuleShape, QrStyle, QrLogo

Source of truth: `lib/src/model/qr_style.dart`, `lib/src/model/qr_logo.dart`. Barrel: `package:xue_hua_qr_code/xue_hua_qr_code.dart`.

## `enum QrModuleShape`

Preset for data-module geometry. Finder and alignment patterns always use rounded-rect construction driven by `effectiveModuleRadius`, not this enum's circle oval path.

| Value | Meaning | Default `effectiveModuleRadius` | Default `effectiveModuleGap` |
| --- | --- | --- | --- |
| `square` | Axis-aligned squares (library default) | `0.0` | `0.0` |
| `circle` | Ovals inscribed in each data-module rect | `0.5` | `0.1` |
| `roundedSquare` | Rounded rects for data modules | `0.3` | `0.1` |

No extra enum fields or methods.

## `class QrStyle` (`@immutable`)

Appearance of modules, background, quiet zone. `const QrStyle()` is standard black-on-white.

### Constructor

```dart
const QrStyle({
  this.shape = QrModuleShape.square,
  this.color = const Color(0xFF000000),
  this.backgroundColor = const Color(0xFFFFFFFF),
  this.gradient,
  this.moduleRadius,
  this.moduleGap,
  this.padding = const EdgeInsets.all(8),
});
```

**Asserts** (constructor):

- `moduleRadius == null || (moduleRadius >= 0 && moduleRadius <= 0.5)`
- `moduleGap == null || (moduleGap >= 0 && moduleGap <= 0.5)`

| Field | Type | Default | Notes |
| --- | --- | --- | --- |
| `shape` | `QrModuleShape` | `square` | Data-module path kind. |
| `color` | `Color` | `Color(0xFF000000)` | Dark-module fill when `gradient` is null. |
| `backgroundColor` | `Color` | `Color(0xFFFFFFFF)` | Fills the full paint size including quiet zone when alpha `> 0`. Transparent requires an explicit `Colors.transparent` (or any color with alpha 0). Also the fallback logo backdrop color. |
| `gradient` | `Gradient?` | `null` | Any Flutter `Gradient`. Non-null → `gradient.createShader(contentRect)` on the foreground path; `color` unused. |
| `moduleRadius` | `double?` | `null` | Corner radius as a **fraction of the module (or pattern) shortest side**, `0..0.5`. `null` → `effectiveModuleRadius`. |
| `moduleGap` | `double?` | `null` | Gap as a **fraction of module size**, `0..0.5`. Applied as `deflate(cell * effectiveModuleGap / 2)` on **data** modules only. `null` → `effectiveModuleGap`. |
| `padding` | `EdgeInsets` | `EdgeInsets.all(8)` | Quiet zone in logical pixels. Deflates the paint size; remaining shortest side is the square content. Same value for widget and export. |

### `double get effectiveModuleRadius`

```dart
moduleRadius ??
  switch (shape) {
    QrModuleShape.square => 0.0,
    QrModuleShape.circle => 0.5,
    QrModuleShape.roundedSquare => 0.3,
  };
```

Used for finder/alignment rounded rects and for square/roundedSquare data modules. Circle data modules use `path.addOval` and ignore this for the oval itself; finder/alignment still use it.

### `double get effectiveModuleGap`

```dart
moduleGap ??
  switch (shape) {
    QrModuleShape.square => 0.0,
    QrModuleShape.circle => 0.1,
    QrModuleShape.roundedSquare => 0.1,
  };
```

### `QrStyle copyWith({...})`

```dart
QrStyle copyWith({
  QrModuleShape? shape,
  Color? color,
  Color? backgroundColor,
  Gradient? gradient,
  double? moduleRadius,
  double? moduleGap,
  EdgeInsets? padding,
})
```

Each argument uses `?? this.field`. Passing `null` keeps the existing value, including `gradient`. To remove a gradient, construct a new `QrStyle` without `gradient`.

`moduleRadius` / `moduleGap` passed through are still subject to the constructor asserts.

### `@override bool operator ==(Object other)`

Equal when `identical` or `other is QrStyle` and all seven fields compare equal: `shape`, `color`, `backgroundColor`, `gradient`, `moduleRadius`, `moduleGap`, `padding`.

### `@override int get hashCode`

```dart
Object.hash(shape, color, backgroundColor, gradient, moduleRadius, moduleGap, padding)
```

No `toString` override.

## `class QrLogo` (`@immutable`)

Center-logo configuration. Size is a fraction of the **content** square (inside quiet zone), identical on screen and in export.

### Constructor

```dart
const QrLogo({
  required this.image,
  this.scale = 0.2,
  this.padding = 4,
  this.backgroundColor,
  this.borderRadius = 0,
});
```

**Asserts**:

- `scale > 0 && scale <= 0.35` (message: `scale must be within 0~0.35; larger logos break scannability / 过大的 Logo 会破坏可扫性`)
- `padding >= 0`
- `borderRadius >= 0`

| Field | Type | Default | Notes |
| --- | --- | --- | --- |
| `image` | `ImageProvider` | required | `AssetImage`, `NetworkImage`, `MemoryImage`, etc. Widget uses `createLocalImageConfiguration(context)`; export uses `ImageConfiguration.empty`. |
| `scale` | `double` | `0.2` | Logo side = `contentSide * scale`. Max `0.35`. Must be `> 0`. |
| `padding` | `double` | `4` | Backdrop inflate around the logo rect, **logical pixels** (not a fraction). Modules overlapping this backdrop are skipped. |
| `backgroundColor` | `Color?` | `null` | Backdrop fill. `null` → `style.backgroundColor`. Drawn only when alpha `> 0`, as `RRect` with `borderRadius`. |
| `borderRadius` | `double` | `0` | Backdrop corner radius in logical pixels. |

The logo bitmap is drawn with `FilterQuality.medium` into the un-inflated `logoRect` (square, centered). Painting happens only when both `logo` and a decoded `ui.Image` are non-null.

### `@override bool operator ==(Object other)`

Equal when `identical` or `other is QrLogo` and `image`, `scale`, `padding`, `backgroundColor`, `borderRadius` all match.

### `@override int get hashCode`

```dart
Object.hash(image, scale, padding, backgroundColor, borderRadius)
```

No `copyWith` and no `toString` override.
