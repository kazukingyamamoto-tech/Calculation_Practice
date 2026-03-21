class AxisItem {
  final int number;
  final String operator;

  AxisItem({required this.number, this.operator = ""});

  // 画面に表示する用の文字列（例: "×3", "5"）
  String get displayText => "$operator$number";
}

String calculateAnswer(AxisItem row, AxisItem col, String mode) {
  switch (mode) {
    case "普通の掛け算":
    case "上級の掛け算":
    case "超上級の掛け算":
      return (row.number * col.number).toString();
    case "割り算":
      if (row.number != 0) {
        return _divisionCalculate(row.number, col.number);
      } else {
        return "Error"; // ゼロ除算のエラー
      }
    case "ミックス計算":
      if (row.operator == "÷") {
        if (row.number != 0) {
          return _divisionCalculate(row.number, col.number);
        } else {
          return "Error"; // ゼロ除算のエラー
        }
      } else {
        return (row.number * col.number).toString();
      }
    case "最大公約数":
      return _gcd(row.number,col.number).toString();
    case "循環":
      return _cycle(row.number,col.number).toString();
    default:
      return "";
  }
}

int _gcd(int x, int y) {
  if (y == 0) return x;
  return _gcd(y, x % y);
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

int _cycle(int b,int a) {
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