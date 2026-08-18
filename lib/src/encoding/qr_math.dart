/// Galois-field and geometry helpers for QR encoding.
/// QR 编码用的伽罗瓦域与几何辅助方法。
class QrMath {
  QrMath._();

  static final List<int> _expTable = List<int>.filled(256, 0);
  static final List<int> _logTable = List<int>.filled(256, 0);
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    for (var i = 0; i <= 7; i++) {
      _expTable[i] = 1 << i;
    }
    for (var i = 8; i <= 255; i++) {
      _expTable[i] = _expTable[i - 4] ^ _expTable[i - 5] ^ _expTable[i - 6] ^ _expTable[i - 8];
    }
    for (var i = 0; i <= 254; i++) {
      _logTable[_expTable[i]] = i;
    }
    _initialized = true;
  }

  static int glog(int n) {
    _ensureInitialized();
    return _logTable[n];
  }

  static int gexp(int n) {
    _ensureInitialized();
    var i = n;
    while (i < 0) {
      i += 255;
    }
    while (i >= 256) {
      i -= 255;
    }
    return _expTable[i];
  }
}
