class GameRecord {
  final String playerName; // プレイヤー名
  final DateTime date; // 日付
  final String time; // タイム (例: "01:25")
  final String mode; // モード (例: "普通の掛け算")
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
      'mode': mode,
      'score': score,
    };
  }

  // 保存された Map からクラスを復元する
  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      playerName: map['playerName'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      mode: map['mode'],
      score: map['score'],
    );
  }
}
