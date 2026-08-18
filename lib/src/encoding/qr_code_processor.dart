import 'bit_buffer.dart';
import 'insufficient_information_density_exception.dart';
import 'polynomial.dart';
import 'qr_code_enums.dart';
import 'qr_code_raw_data.dart';
import 'qr_code_setup.dart';
import 'qr_code_square.dart';
import 'qr_data.dart';
import 'qr_util.dart';
import 'rs_block.dart';

/// 将载荷字符串编码为 QR 模块矩阵(纯编码,不负责绘制)。
class QrCodeProcessor {
  QrCodeProcessor(this._data, {this.errorLevel = QrErrorLevel.medium, QrCodeDataType? dataType})
    : dataType = dataType ?? QrUtil.getDataType(_data) {
    _qrCodeData = _createQrData(this.dataType, _data);
  }

  final String _data;

  /// 纠错等级。
  final QrErrorLevel errorLevel;

  /// 数据段编码模式(按内容自动推断)。
  final QrCodeDataType dataType;

  late final QrData _qrCodeData;

  // 同一版本下 RS 编码结果不变;缓存后 8 种掩码评估只需计算一次。
  List<int>? _cachedBytes;
  int? _cachedBytesType;

  /// 最大 QR 版本号(40)。
  static const int maximumInfoDensity = 40;
  static const int _pad0 = 0xEC;
  static const int _pad1 = 0x11;

  static QrData _createQrData(QrCodeDataType type, String data) {
    switch (type) {
      case QrCodeDataType.numbers:
        return QrNumber(data);
      case QrCodeDataType.upperAlphaNum:
        return QrAlphaNum(data);
      case QrCodeDataType.defaultType:
        return Qr8BitByte(data);
    }
  }

  /// 在给定纠错等级下,能容纳 [data] 的最小 QR 版本(1–40,按 bit 容量计算)。
  static int minTypeForData(String data, QrErrorLevel errorLevel, [QrCodeDataType? dataType]) {
    final resolvedDataType = dataType ?? QrUtil.getDataType(data);
    final qrCodeData = _createQrData(resolvedDataType, data);

    for (var typeNum = 1; typeNum < errorLevel.maxTypeNum; typeNum++) {
      if (_fitsInType(qrCodeData, typeNum, errorLevel)) {
        return typeNum;
      }
    }

    if (_fitsInType(qrCodeData, maximumInfoDensity, errorLevel)) {
      return maximumInfoDensity;
    }

    final rsBlocks = RsBlock.getRsBlocks(maximumInfoDensity, errorLevel);
    final buffer = _buildDataBuffer(qrCodeData, maximumInfoDensity);
    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;
    throw InsufficientInformationDensityException(
      'Data exceeds maximum QR capacity at version $maximumInfoDensity '
      '[neededBits=${buffer.lengthInBits}, maximumBitsForDensityLevel=$totalDataCount].',
    );
  }

  static bool _fitsInType(QrData qrCodeData, int typeNum, QrErrorLevel errorLevel) {
    final rsBlocks = RsBlock.getRsBlocks(typeNum, errorLevel);
    final buffer = _buildDataBuffer(qrCodeData, typeNum);
    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;
    return buffer.lengthInBits <= totalDataCount;
  }

  static BitBuffer _buildDataBuffer(QrData qrCodeData, int typeNum) {
    final buffer = BitBuffer();
    buffer.putNum(qrCodeData.dataType.value, 4);
    buffer.putNum(qrCodeData.length(), qrCodeData.getLengthInBits(typeNum));
    qrCodeData.write(buffer);
    return buffer;
  }

  /// 按 [type](版本)与 [maskPattern] 编码,返回模块矩阵。
  QrCodeRawData encode({int? type, MaskPattern maskPattern = MaskPattern.pattern000}) {
    final resolvedType = type ?? minTypeForData(_data, errorLevel, dataType);
    final moduleCount = resolvedType * 4 + 17;
    final modules = List.generate(
      moduleCount,
      (_) => List<QrCodeSquare?>.filled(moduleCount, null),
    );

    QrCodeSetup.setupTopLeftPositionProbePattern(modules);
    QrCodeSetup.setupTopRightPositionProbePattern(modules);
    QrCodeSetup.setupBottomLeftPositionProbePattern(modules);
    QrCodeSetup.setupPositionAdjustPattern(resolvedType, modules);
    QrCodeSetup.setupTimingPattern(moduleCount, modules);
    QrCodeSetup.setupTypeInfo(errorLevel, maskPattern, moduleCount, modules);

    if (resolvedType >= 7) {
      QrCodeSetup.setupTypeNumber(resolvedType, moduleCount, modules);
    }

    final encodedData = _createData(resolvedType);
    QrCodeSetup.applyMaskPattern(encodedData, maskPattern, moduleCount, modules);

    return List.generate(moduleCount, (row) {
      return List.generate(moduleCount, (column) {
        return modules[row][column] ??
            QrCodeSquare(dark: false, row: row, col: column, moduleSize: moduleCount);
      });
    });
  }

  List<int> _createData(int type) {
    if (_cachedBytesType == type && _cachedBytes != null) {
      return _cachedBytes!;
    }

    final rsBlocks = RsBlock.getRsBlocks(type, errorLevel);
    final buffer = _buildDataBuffer(_qrCodeData, type);

    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;

    if (buffer.lengthInBits > totalDataCount) {
      throw InsufficientInformationDensityException(
        'Insufficient Information Density Parameter: $type '
        '[neededBits=${buffer.lengthInBits}, maximumBitsForDensityLevel=$totalDataCount] - '
        'Try increasing the Information Density parameter value or use 0 (zero) to automatically '
        'compute the least amount needed to fit the QRCode data being encoded.',
      );
    }

    if (buffer.lengthInBits + 4 <= totalDataCount) {
      buffer.putNum(0, 4);
    }

    while (buffer.lengthInBits % 8 != 0) {
      buffer.put(false);
    }

    while (true) {
      if (buffer.lengthInBits >= totalDataCount) break;
      buffer.putNum(_pad0, 8);
      if (buffer.lengthInBits >= totalDataCount) break;
      buffer.putNum(_pad1, 8);
    }

    final bytes = _createBytes(buffer, rsBlocks);
    _cachedBytes = bytes;
    _cachedBytesType = type;
    return bytes;
  }

  List<int> _createBytes(BitBuffer buffer, List<RsBlock> rsBlocks) {
    var offset = 0;
    var maxDcCount = 0;
    var maxEcCount = 0;
    var totalCodeCount = 0;
    final dcData = List<List<int>>.generate(rsBlocks.length, (_) => []);
    final ecData = List<List<int>>.generate(rsBlocks.length, (_) => []);

    for (var i = 0; i < rsBlocks.length; i++) {
      final block = rsBlocks[i];
      final dcCount = block.dataCount;
      final ecCount = block.totalCount - dcCount;

      totalCodeCount += block.totalCount;
      maxDcCount = maxDcCount < dcCount ? dcCount : maxDcCount;
      maxEcCount = maxEcCount < ecCount ? ecCount : maxEcCount;

      dcData[i] = List<int>.generate(dcCount, (idx) => 0xff & buffer.buffer[idx + offset]);
      offset += dcCount;

      final rsPoly = QrUtil.getErrorCorrectPolynomial(ecCount);
      final rawPoly = Polynomial(dcData[i], rsPoly.len() - 1);
      final modPoly = rawPoly.mod(rsPoly);
      final ecDataSize = rsPoly.len() - 1;

      ecData[i] = List<int>.generate(ecDataSize, (idx) {
        final modIndex = idx + modPoly.len() - ecDataSize;
        return modIndex >= 0 ? modPoly[modIndex] : 0;
      });
    }

    var index = 0;
    final data = List<int>.filled(totalCodeCount, 0);

    for (var i = 0; i < maxDcCount; i++) {
      for (var r = 0; r < rsBlocks.length; r++) {
        if (i < dcData[r].length) {
          data[index++] = dcData[r][i];
        }
      }
    }

    for (var i = 0; i < maxEcCount; i++) {
      for (var r = 0; r < rsBlocks.length; r++) {
        if (i < ecData[r].length) {
          data[index++] = ecData[r][i];
        }
      }
    }

    return data;
  }

  @override
  String toString() => 'QrCodeProcessor(data=$_data, errorLevel=$errorLevel, dataType=$dataType)';
}
