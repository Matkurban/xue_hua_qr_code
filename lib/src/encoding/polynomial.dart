import 'qr_math.dart';

/// Polynomial over GF(256) for Reed–Solomon error correction.
/// GF(256) 上的多项式，用于 Reed–Solomon 纠错。
class Polynomial {
  Polynomial(List<int> num, [int shift = 0]) : data = _initData(num, shift);

  final List<int> data;

  static List<int> _initData(List<int> num, int shift) {
    var offset = 0;
    for (var i = 0; i < num.length; i++) {
      if (num[i] != 0) {
        offset = i;
        break;
      }
    }
    final result = List<int>.filled(num.length - offset + shift, 0);
    for (var i = 0; i < num.length - offset; i++) {
      result[i] = num[offset + i];
    }
    return result;
  }

  int operator [](int i) => data[i];

  int len() => data.length;

  List<int> toList() => List<int>.from(data);

  Polynomial multiply(Polynomial other) {
    final result = List<int>.filled(len() + other.len() - 1, 0);
    for (var i = 0; i < len(); i++) {
      for (var j = 0; j < other.len(); j++) {
        result[i + j] = result[i + j] ^ QrMath.gexp(QrMath.glog(this[i]) + QrMath.glog(other[j]));
      }
    }
    return Polynomial(result);
  }

  Polynomial mod(Polynomial other) {
    if (len() - other.len() < 0) {
      return this;
    }
    final ratio = QrMath.glog(this[0]) - QrMath.glog(other[0]);
    final result = List<int>.from(data);
    for (var i = 0; i < other.data.length; i++) {
      result[i] = result[i] ^ QrMath.gexp(QrMath.glog(other.data[i]) + ratio);
    }
    return Polynomial(result).mod(other);
  }
}
