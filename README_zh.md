**语言:** [English](README.md) | [中文](README_zh.md)

# xue_hua_qr_code

开箱即用的 Flutter 二维码组件。纯 Dart 实现,无原生依赖、无平台通道。

```dart
XueHuaQrCode(value: 'https://example.com')
```

只需一个参数,即可得到自适应父级约束、可正常扫描的标准黑白二维码。

## 特性

- **仅一个必填参数** — 传入 `value` 即渲染,所有其它参数均有合理默认值
- **样式定制** — 方形 / 圆形 / 圆角模块,纯色、渐变,比例制圆角与间距
- **中心 Logo** — 基于 `ImageProvider`,以二维码边长比例定尺寸,组件显示与导出完全一致
- **掩码自动选择** — 按 ISO/IEC 18004 罚分规则在 8 种掩码中自动选取最优,保证可扫性
- **健壮的错误处理** — 空内容 / 超长内容走 `errorBuilder` 降级;Logo 加载失败(如网络错误)自动降级为完整无 Logo 二维码,绝不产生不可扫的空洞
- **导出能力** — `XueHuaQrCode.toImage()` 与 `XueHuaQrCode.toPngBytes()`,与组件共用同一绘制实现,所见即所得

## 安装

```yaml
dependencies:
  xue_hua_qr_code: ^lasted_version
```

## 基础用法

```dart
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

// 自适应父级约束的最短边。
XueHuaQrCode(value: 'https://example.com')

// 固定尺寸。
XueHuaQrCode(value: 'https://example.com', size: 240)
```

## 进阶用法

### 自定义样式

```dart
XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(
    shape: QrModuleShape.roundedSquare,
    moduleRadius: 0.4,           // 模块尺寸的比例,0~0.5
    moduleGap: 0.15,             // 模块尺寸的比例,0~0.5
    gradient: LinearGradient(colors: [Colors.pink, Colors.blue]),
    padding: EdgeInsets.all(12), // 静默区
  ),
)
```

### 带 Logo

```dart
XueHuaQrCode(
  value: 'https://example.com',
  size: 240,
  style: const QrStyle(shape: QrModuleShape.roundedSquare),
  logo: const QrLogo(
    image: AssetImage('assets/logo.png'), // 也支持 NetworkImage / MemoryImage
    scale: 0.22,      // 占二维码边长的比例,上限 0.35
    padding: 6,
    borderRadius: 8,
  ),
  // 带 Logo 时纠错等级自动升为 high,无需手动设置。
)
```

Logo 加载失败(资源缺失、网络错误)时,组件渲染完整的无 Logo 二维码,不会留下不可扫描的空洞。

### 错误处理

```dart
XueHuaQrCode(
  value: userInput, // 可能为空或超长
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
)
```

### 导出

```dart
// PNG 字节 — 可保存文件或用 Image.memory 显示。
final bytes = await XueHuaQrCode.toPngBytes(
  'https://example.com',
  size: 512,
  style: const QrStyle(shape: QrModuleShape.circle),
);

// dart:ui 的 Image。
final image = await XueHuaQrCode.toImage('https://example.com', size: 512);
```

## API 参考

### `XueHuaQrCode`

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | `String` | 必填 | 要编码的内容 |
| `size` | `double?` | `null` | 固定边长;null 时自适应父级约束 |
| `style` | `QrStyle` | `QrStyle()` | 外观样式 |
| `logo` | `QrLogo?` | `null` | 中心 Logo |
| `errorCorrectionLevel` | `QrErrorLevel?` | 自动 | 无 Logo 为 `medium`,带 Logo 为 `high` |
| `errorBuilder` | `ImageErrorWidgetBuilder?` | `null` | 编码失败时的降级 UI |
| `semanticsLabel` | `String?` | `'QR code'` | 无障碍语义标签 |

### `QrStyle`

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `shape` | `QrModuleShape` | `square` | `square` / `circle` / `roundedSquare` |
| `color` | `Color` | 黑色 | 前景色(设置 `gradient` 时忽略) |
| `backgroundColor` | `Color` | 白色 | 背景色;需要透明请显式传 `Colors.transparent` |
| `gradient` | `Gradient?` | `null` | 前景渐变(任意 Flutter `Gradient`) |
| `moduleRadius` | `double?` | 随形状 | 模块圆角,为模块尺寸的比例,0~0.5 |
| `moduleGap` | `double?` | 随形状 | 模块间距,为模块尺寸的比例,0~0.5 |
| `padding` | `EdgeInsets` | `EdgeInsets.all(8)` | 二维码四周的静默区 |

### `QrLogo`

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `image` | `ImageProvider` | 必填 | Logo 图片 |
| `scale` | `double` | `0.2` | Logo 边长占二维码边长的比例,上限 0.35 |
| `padding` | `double` | `4` | Logo 底衬留白(逻辑像素) |
| `backgroundColor` | `Color?` | 样式背景色 | 底衬颜色 |
| `borderRadius` | `double` | `0` | 底衬圆角(逻辑像素) |

### `QrErrorLevel`

`low`(约 7%)、`medium`(约 15%)、`quartile`(约 25%)、`high`(约 30%)— 数值为大致可恢复的数据比例。

### 导出方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `XueHuaQrCode.toImage(value, {size, style, logo, errorCorrectionLevel})` | `Future<ui.Image>` | 渲染为 `dart:ui` 图片 |
| `XueHuaQrCode.toPngBytes(value, {size, style, logo, errorCorrectionLevel})` | `Future<Uint8List>` | 渲染为 PNG 字节 |

导出与组件显示共用同一绘制器,所见即所得。

## 示例应用

```bash
cd example
flutter run
```

五个标签页演示基础、圆形、圆角、渐变、Logo 样式,并含 PNG 导出。

## 许可证

MIT — 编码内核移植自 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin)。
