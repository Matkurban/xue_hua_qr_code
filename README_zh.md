**语言:** [English](README.md) | [中文](README_zh.md)

# xue_hua_qr_code

**在线演示：** [https://matkurban.github.io/xue_hua_qr_code/](https://matkurban.github.io/xue_hua_qr_code/)

开箱即用的 Flutter 二维码组件。纯 Dart 实现,无原生依赖、无平台通道。

```dart
XueHuaQrCode(value: 'https://example.com')
```

只需一个参数,即可得到自适应父级约束、可正常扫描的标准黑白二维码。

## 特性

- **仅一个必填参数** — 传入 `value` 即渲染,所有其它参数均有合理默认值
- **样式定制** — 方形 / 圆形 / 圆角模块,纯色、渐变,比例制圆角与间距
- **中心 Logo** — 基于 `ImageProvider`,以二维码内容边长比例定尺寸,组件显示与导出完全一致
- **掩码自动选择** — 按 ISO/IEC 18004 罚分规则在 8 种掩码中自动选取最优,保证可扫性
- **健壮的错误处理** — 组件上空内容 / 超长内容走 `errorBuilder` 降级;Logo 加载失败(如网络错误)自动降级为完整无 Logo 二维码,绝不产生不可扫的空洞
- **导出能力** — `XueHuaQrCode.toImage()` 与 `XueHuaQrCode.toPngBytes()`,与组件共用同一绘制实现,所见即所得
- **AI agent skills** — 包内附带官方 Agent Skills,供 Cursor、Claude Code 等助手使用

## 安装

```yaml
dependencies:
  xue_hua_qr_code: ^2.0.2
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
    scale: 0.22,      // 占二维码内容边长的比例,(0, 0.35]
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

组件会捕获编码失败。`toImage` / `toPngBytes` 会把异常重新抛出(空 `value` 为 `ArgumentError`,超过版本 40 容量为 `InsufficientInformationDensityException`)。

### 导出

```dart
// PNG 字节 — 可保存文件或用 Image.memory 显示。
// `size` 默认 512;编码失败会抛异常(与组件不同)。
final bytes = await XueHuaQrCode.toPngBytes(
  'https://example.com',
  size: 512,
  style: const QrStyle(shape: QrModuleShape.circle),
);

// dart:ui 的 Image。用完后请 dispose。
final image = await XueHuaQrCode.toImage('https://example.com', size: 512);
```

## API 参考

### `XueHuaQrCode`

| 参数                     | 类型                         | 默认值         | 说明                                                    |
|------------------------|----------------------------|-------------|-------------------------------------------------------|
| `value`                | `String`                   | 必填          | 要编码的内容                                                |
| `size`                 | `double?`                  | `null`      | 固定逻辑边长;`null` 时取父级最短的有限约束                             |
| `style`                | `QrStyle`                  | `QrStyle()` | 外观样式                                                  |
| `logo`                 | `QrLogo?`                  | `null`      | 中心 Logo                                               |
| `errorCorrectionLevel` | `QrErrorLevel?`            | `null`      | 由 `effectiveErrorLevel` 自动决定:无 Logo 为 `medium`,有则为 `high` |
| `errorBuilder`         | `ImageErrorWidgetBuilder?` | `null`      | 编码失败时的降级 UI;未提供时 debug 显示错误占位,release 显示空白           |
| `semanticsLabel`       | `String?`                  | `null`      | 无障碍语义标签;`null` 时显示为 `'QR code'`                       |

`QrErrorLevel get effectiveErrorLevel` — 若设置了 `errorCorrectionLevel` 则用之,否则 `logo != null` 时为 `high`,否则为 `medium`。

### `QrStyle`

| 参数                | 类型              | 默认值                 | 说明                                          |
|-------------------|-----------------|---------------------|---------------------------------------------|
| `shape`           | `QrModuleShape` | `square`            | `square` / `circle` / `roundedSquare`       |
| `color`           | `Color`         | `Color(0xFF000000)` | 前景色(设置 `gradient` 时忽略)                      |
| `backgroundColor` | `Color`         | `Color(0xFFFFFFFF)` | 背景色;需要透明请显式传 `Colors.transparent`           |
| `gradient`        | `Gradient?`     | `null`              | 前景渐变(任意 Flutter `Gradient`)                 |
| `moduleRadius`    | `double?`       | 随形状                 | 模块圆角,为模块尺寸的比例,0~0.5                         |
| `moduleGap`       | `double?`       | 随形状                 | 模块间距,为模块尺寸的比例,0~0.5                         |
| `padding`         | `EdgeInsets`    | `EdgeInsets.all(8)` | 二维码四周的静默区(逻辑像素),组件与导出共用                      |

`moduleRadius` / `moduleGap` 为 `null` 时,`effectiveModuleRadius` / `effectiveModuleGap` 按形状取值:`square` → `0.0` / `0.0`,`circle` → `0.5` / `0.1`,`roundedSquare` → `0.3` / `0.1`。

`copyWith` 使用 `??`,无法把 `gradient` 清回 `null`;去掉渐变需重新构造 `QrStyle`。

### `QrLogo`

| 参数                | 类型              | 默认值   | 说明                                         |
|-------------------|-----------------|-------|--------------------------------------------|
| `image`           | `ImageProvider` | 必填    | Logo 图片                                    |
| `scale`           | `double`        | `0.2` | Logo 边长占二维码**内容**边长的比例,`(0, 0.35]`         |
| `padding`         | `double`        | `4`   | Logo 底衬留白(逻辑像素)                            |
| `backgroundColor` | `Color?`        | `null` | 底衬颜色;`null` 时使用 `style.backgroundColor`    |
| `borderRadius`    | `double`        | `0`   | 底衬圆角(逻辑像素)                                 |

### `QrErrorLevel`

`low`(约 7%)、`medium`(约 15%)、`quartile`(约 25%)、`high`(约 30%)— 数值为大致可恢复的数据比例。

公开字段 `value`(格式信息 BCH:L=1,M=0,Q=3,H=2)与 `maxTypeNum`(编码器搜版本时的上界)供编码器使用。应用代码请传枚举名。

### 导出方法

| 方法                                                                                | 返回值                 | 说明               |
|-----------------------------------------------------------------------------------|---------------------|------------------|
| `XueHuaQrCode.toImage(value, {size = 512, style, logo, errorCorrectionLevel})`    | `Future<ui.Image>`  | 渲染为 `dart:ui` 图片 |
| `XueHuaQrCode.toPngBytes(value, {size = 512, style, logo, errorCorrectionLevel})` | `Future<Uint8List>` | 渲染为 PNG 字节       |

导出与组件显示共用同一绘制器。编码失败会抛异常;Logo 加载失败则降级为完整无 Logo 二维码。`size` 必须 `> 0`。`toImage` 返回的图片用完后请 `dispose`。PNG 编码失败时 `toPngBytes` 可能抛出 `StateError`。

### `QrMatrix`

不可变的编码结果。通过 `QrMatrix.encode(value, {errorLevel = QrErrorLevel.medium})` 创建。

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `value` | `String` | 编码的原始内容 |
| `errorLevel` | `QrErrorLevel` | 本次编码使用的纠错等级 |
| `version` | `int` | QR 版本 1–40 |
| `moduleCount` | `int` | 每边模块数(`version * 4 + 17`) |
| `alignmentCenters` | `List<(int, int)>` | 对齐图案中心 `(row, col)` |
| `finderOrigins` | `List<(int, int)>` | 三个 7×7 定位图案的左上角 |
| `isDark(row, col)` | `bool` | 该模块是否为深色 |
| `isInFinderPattern(row, col)` | `bool` | 是否在 7×7 定位图案内 |
| `isInAlignmentPattern(row, col)` | `bool` | 是否在 5×5 对齐图案内 |

空 `value` 抛出 `ArgumentError`。超容量抛出 `InsufficientInformationDensityException`。相等性只比较 `value` 与 `errorLevel`。

### `QrPainter`

组件与导出共用的 `CustomPainter`。

```dart
const QrPainter({
  required QrMatrix matrix,
  QrStyle style = const QrStyle(),
  QrLogo? logo,
  ui.Image? logoImage,
})
```

`paint` / `shouldRepaint` 遵循 `CustomPainter`。仅当 `logo` 与 `logoImage` 均非 null 时绘制 Logo;否则绘制完整矩阵,不挖空中心。

### `InsufficientInformationDensityException`

载荷在所选纠错等级下无法放入 QR 版本 40 时抛出。可选 `message` 含所需与最大 bit 数。`toString()` 为 `InsufficientInformationDensityException: ${message ?? ''}`。

没有公开的版本覆盖接口:`QrMatrix.encode` 始终自动选择能容纳数据的最小版本。

## AI agent skills

本包附带 Agent Skills,供 AI 编程助手按公开 API 正确生成代码。添加依赖后安装:

```bash
dart run skills@ get
```

该命令扫描依赖,把选中的 skill 复制到助手的 skills 目录(例如 `.agents/skills/` 或 `.cursor/skills/`)。升级本包后请再跑一次。

| Skill | 用途 |
| --- | --- |
| `xue-hua-qr-code-widget` | `XueHuaQrCode`、`QrErrorLevel`、`errorBuilder`、`toImage` / `toPngBytes` |
| `xue-hua-qr-code-styling` | `QrStyle`、`QrModuleShape`、`QrLogo` |
| `xue-hua-qr-code-painter` | `QrMatrix`、`QrPainter`、自定义 `CustomPaint` |

每个 skill 的 `references/` 列出全部公开构造函数、字段、getter 与方法。若助手从其它目录读取 skills,可直接复制本仓库 `skills/` 下的文件夹。

## 示例应用

```bash
cd example
flutter run
```

五个标签页演示基础、圆形、圆角、渐变、Logo 样式,并含 PNG 导出。

## 许可证

MIT — 编码内核移植自 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin)。
