/// Growable bit stream for QR payload encoding.
/// 用于 QR 载荷编码的可增长比特流。
class BitBuffer {
  BitBuffer() {
    buffer = List<int>.filled(_increments, 0);
    lengthInBits = 0;
  }

  static const int _increments = 32;

  late List<int> buffer;
  int lengthInBits = 0;

  bool _get(int index) => (buffer[index ~/ 8] >>> (7 - index % 8)) & 1 == 1;

  void putNum(int num, int length) {
    for (var i = 0; i < length; i++) {
      put((num >>> (length - i - 1)) & 1 == 1);
    }
  }

  void put(bool bit) {
    if (lengthInBits == buffer.length * 8) {
      final newBuffer = List<int>.filled(buffer.length + _increments, 0);
      for (var i = 0; i < buffer.length; i++) {
        newBuffer[i] = buffer[i];
      }
      buffer = newBuffer;
    }
    if (bit) {
      buffer[lengthInBits ~/ 8] = buffer[lengthInBits ~/ 8] | (0x80 >>> (lengthInBits % 8));
    }
    lengthInBits++;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (var i = 0; i < lengthInBits; i++) {
      sb.write(_get(i) ? '1' : '0');
    }
    return sb.toString();
  }
}
