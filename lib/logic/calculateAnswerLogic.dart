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
    case "普通のかけ算":
    case "普通の掛け算":
    case "上級のかけ算":
    case "上級の掛け算":
    case "超上級のかけ算":
    case "超上級の掛け算":
      return (row.number * col.number).toString();
    case "かけ算（小数）":
    case "小数の掛け算":
      return _decimalMultiplicationCalculate(row.number, col.number);
    case "わり算（分数）":
    case "割り算（分数）":
    case "上級のわり算（分数）":
    case "上級の割り算（分数）":
      if (col.number != 0) {
        return _divisionCalculate(col.number, row.number);
      } else {
        return "Error"; // ゼロ除算のエラー
      }
    case "分数の足し算":
      return _fractionAdditionCalculate(row, col);
    case "わり算（小数）":
    case "割り算（小数）":
    case "上級のわり算（小数）":
    case "上級の割り算（小数）":
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
    case "循環する一の位":
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

String _fractionAdditionCalculate(AxisItem left, AxisItem right) {
  final leftFraction = _parseFraction(left.displayText);
  final rightFraction = _parseFraction(right.displayText);
  if (leftFraction == null || rightFraction == null) {
    return "Error";
  }

  final a = leftFraction.$1;
  final b = leftFraction.$2;
  final c = rightFraction.$1;
  final d = rightFraction.$2;

  final numerator = (a * d) + (c * b);
  final denominator = b * d;
  if (denominator == 0) {
    return "Error";
  }

  final gcd = _gcd(numerator.abs(), denominator.abs());
  final reducedNumerator = numerator ~/ gcd;
  final reducedDenominator = denominator ~/ gcd;

  if (reducedDenominator == 1) {
    return reducedNumerator.toString();
  }
  return "$reducedNumerator/$reducedDenominator";
}

(int, int)? _parseFraction(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  if (!trimmed.contains('/')) {
    final integerValue = int.tryParse(trimmed);
    if (integerValue == null) {
      return null;
    }
    return (integerValue, 1);
  }

  final parts = trimmed.split('/');
  if (parts.length != 2) {
    return null;
  }

  final numerator = int.tryParse(parts[0]);
  final denominator = int.tryParse(parts[1]);
  if (numerator == null || denominator == null || denominator == 0) {
    return null;
  }
  return (numerator, denominator);
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
  return rounded.toStringAsFixed(1);
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
