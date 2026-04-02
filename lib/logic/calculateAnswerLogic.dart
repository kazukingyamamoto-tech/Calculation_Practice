class AxisItem {
  final int number;
  final String operator;
  final String? displayOverride;

  AxisItem({required this.number, this.operator = "", this.displayOverride});

  // 画面に表示する用の文字列（例: "×3", "5"）
  String get displayText => displayOverride ?? "$operator$number";
}

String calculateAnswer(AxisItem row, AxisItem col, String mode) {
  switch (mode) {
    case "普通の掛け算":
    case "上級の掛け算":
    case "超上級の掛け算":
      return (row.number * col.number).toString();
    case "少数の掛け算":
      return _decimalMultiplicationCalculate(row.number, col.number);
    case "割り算（分数）":
      if (col.number != 0) {
        return _divisionCalculate(col.number, row.number);
      } else {
        return "Error"; // ゼロ除算のエラー
      }
    case "割り算（少数）":
    case "上級の割り算（少数）":
      if (col.number != 0) {
        return _divisionDecimalCalculate(col.number, row.number);
      } else {
        return "Error";
      }
    case "ミックス計算":
      if (col.operator == "÷") {
        if (col.number != 0) {
          return _divisionCalculate(col.number, row.number);
        } else {
          return "Error"; // ゼロ除算のエラー
        }
      } else {
        return (row.number * col.number).toString();
      }
    case "最大公約数":
      return _gcd(row.number, col.number).toString();
    case "最小公倍数":
      return _lcm(row.number, col.number).toString();
    case "循環":
      return _cycle(row.number, col.number).toString();
    default:
      return "";
  }
}

int _gcd(int x, int y) {
  if (y == 0) return x;
  return _gcd(y, x % y);
}

int _lcm(int x, int y) {
  if (x == 0 || y == 0) return 0;
  return (x ~/ _gcd(x, y)) * y;
}

String _divisionCalculate(int b, int a) {
  if (a % b == 0) {
    return (a ~/ b).toString(); // 割り切れる場合は整数を返す
  } else {
    int gcd = _gcd(a, b);
    a ~/= gcd;
    b ~/= gcd;
    return "$a/$b";
  }
}

String _decimalMultiplicationCalculate(int scaledBy10, int multiplier) {
  final productScaledBy10 = scaledBy10 * multiplier;
  final integerPart = productScaledBy10 ~/ 10;
  final decimalPart = productScaledBy10 % 10;

  if (decimalPart == 0) {
    return integerPart.toString();
  }
  return '$integerPart.$decimalPart';
}

String _divisionDecimalCalculate(int divisor, int dividend) {
  if (dividend % divisor == 0) {
    return (dividend ~/ divisor).toString();
  }

  final rounded = ((dividend / divisor) * 100).round() / 100;
  return rounded.toStringAsFixed(2);
}

int _cycle(int b, int a) {
  if (b == 0) return 1;
  int lastDigitOfBase = a % 10;

  int expMod4 = b % 4;
  if (expMod4 == 0) expMod4 = 4;

  int result = 1;
  for (int i = 0; i < expMod4; i++) {
    result = (result * lastDigitOfBase) % 10;
  }

  return result;
}
