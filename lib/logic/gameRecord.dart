class GameRecord {
  final String playerName; // プレイヤー名
  final DateTime date; // 日付
  final String time; // タイム (例: "01:25")
  final String mode; // モード (例: "普通のかけ算")
  final int score; // 正解数

  GameRecord({
    required this.playerName,
    required this.date,
    required this.time,
    required this.mode,
    required this.score,
  });

  // 保存するためにクラスを Map (辞書形式) に変換する
  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'date': date.toIso8601String(), // 日時を文字列にする
      'time': time,
      'mode': normalizeModeName(mode),
      'score': score,
    };
  }

  static String normalizeModeName(String rawMode) {
    switch (rawMode) {
      case '普通の掛け算':
        return '普通のかけ算';
      case '上級の掛け算':
        return '上級のかけ算';
      case '超上級の掛け算':
        return '超上級のかけ算';
      case '小数の掛け算':
        return 'かけ算（小数）';
      case '割り算（分数）':
        return 'わり算（分数）';
      case '割り算（小数）':
        return 'わり算（小数）';
      case '上級の割り算（小数）':
        return '上級のわり算（小数）';
      case '最大公約数の計算':
        return '最大公約数';
      case '最小公倍数の計算':
        return '最小公倍数';
      case 'カスタム':
        return 'カスタムモード';
      default:
        return rawMode;
    }
  }

  // 保存された Map からクラスを復元する
  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      playerName: map['playerName'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      mode: normalizeModeName(map['mode'] as String),
      score: map['score'],
    );
  }
}
