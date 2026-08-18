/// 开箱即用的 Flutter 二维码组件。
///
/// 核心入口:
/// - [XueHuaQrCode]:二维码组件,仅传 `value` 即可渲染。
/// - [QrStyle] / [QrLogo]:外观样式与中心 Logo 配置。
/// - [XueHuaQrCode.toImage] / [XueHuaQrCode.toPngBytes]:导出图片。
library;

export 'src/encoding/insufficient_information_density_exception.dart';
export 'src/encoding/qr_code_enums.dart' show QrErrorLevel;
export 'src/model/qr_logo.dart';
export 'src/model/qr_matrix.dart';
export 'src/model/qr_style.dart';
export 'src/painting/qr_painter.dart';
export 'src/widgets/xue_hua_qr_code.dart';
