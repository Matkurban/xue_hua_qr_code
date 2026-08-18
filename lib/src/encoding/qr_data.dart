import 'qr_code_enums.dart';
import 'bit_buffer.dart';

/// Payload segment that writes itself into a [BitBuffer].
/// 可写入 [BitBuffer] 的载荷数据段。
abstract class QrData {
  QrData(this.dataType, this.data);

  final QrCodeDataType dataType;
  final String data;

  int length();

  void write(BitBuffer buffer);

  int getLengthInBits(int type) {
    if (type >= 1 && type <= 9) {
      switch (dataType) {
        case QrCodeDataType.numbers:
          return 10;
        case QrCodeDataType.upperAlphaNum:
          return 9;
        case QrCodeDataType.defaultType:
          return 8;
      }
    } else if (type >= 10 && type <= 26) {
      switch (dataType) {
        case QrCodeDataType.numbers:
          return 12;
        case QrCodeDataType.upperAlphaNum:
          return 11;
        case QrCodeDataType.defaultType:
          return 16;
      }
    } else if (type >= 27 && type <= 40) {
      switch (dataType) {
        case QrCodeDataType.numbers:
          return 14;
        case QrCodeDataType.upperAlphaNum:
          return 13;
        case QrCodeDataType.defaultType:
          return 16;
      }
    }
    throw ArgumentError("'type' must be greater than 0 and cannot be greater than 40: $type");
  }
}

/// 8-bit byte mode payload. 8 位字节模式载荷。
class Qr8BitByte extends QrData {
  Qr8BitByte(String data) : super(QrCodeDataType.defaultType, data);

  late final List<int> _dataBytes = data.codeUnits;

  @override
  void write(BitBuffer buffer) {
    for (final byte in _dataBytes) {
      buffer.putNum(byte, 8);
    }
  }

  @override
  int length() => _dataBytes.length;
}

/// Alphanumeric mode payload. 字母数字模式载荷。
class QrAlphaNum extends QrData {
  QrAlphaNum(String data) : super(QrCodeDataType.upperAlphaNum, data);

  @override
  void write(BitBuffer buffer) {
    var i = 0;
    final dataLength = data.length;
    while (i + 1 < dataLength) {
      buffer.putNum(_charCode(data[i]) * 45 + _charCode(data[i + 1]), 11);
      i += 2;
    }
    if (i < dataLength) {
      buffer.putNum(_charCode(data[i]), 6);
    }
  }

  @override
  int length() => data.length;

  int _charCode(String c) {
    final ch = c.codeUnitAt(0);
    if (ch >= 0x30 && ch <= 0x39) return ch - 0x30;
    if (ch >= 0x41 && ch <= 0x5A) return ch - 0x41 + 10;
    switch (c) {
      case ' ':
        return 36;
      case r'$':
        return 37;
      case '%':
        return 38;
      case '*':
        return 39;
      case '+':
        return 40;
      case '-':
        return 41;
      case '.':
        return 42;
      case '/':
        return 43;
      case ':':
        return 44;
      default:
        throw ArgumentError('Illegal character: $c');
    }
  }
}

/// Numeric mode payload. 数字模式载荷。
class QrNumber extends QrData {
  QrNumber(String data) : super(QrCodeDataType.numbers, data);

  @override
  void write(BitBuffer buffer) {
    var i = 0;
    final len = length();

    while (i + 2 < len) {
      final num = int.parse(data.substring(i, i + 3));
      buffer.putNum(num, 10);
      i += 3;
    }

    if (i < len) {
      if (len - i == 1) {
        buffer.putNum(int.parse(data.substring(i, i + 1)), 4);
      } else if (len - i == 2) {
        buffer.putNum(int.parse(data.substring(i, i + 2)), 7);
      }
    }
  }

  @override
  int length() => data.length;
}
