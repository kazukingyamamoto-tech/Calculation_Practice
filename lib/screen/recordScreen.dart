import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/GameRecord.dart';
import 'package:fl_chart/fl_chart.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<GameRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords(); // 画面が開いたら読み込む
  }

  // スマホから記録を読み込む
  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('game_records');

    if (recordsJson != null) {
      final List<dynamic> decodedList = jsonDecode(recordsJson);
      setState(() {
        _records = decodedList.map((item) => GameRecord.fromMap(item)).toList();
        // 日付が新しい順に並び替える
        _records.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  // 状態管理用の変数
  String? _selectedPlayer;
  String? _selectedMode;

  // 1. 全記録からユニークなプレイヤー名を取り出す
  List<String> get _players =>
      _records.map((r) => r.playerName).toSet().toList();

  // 2. 選択されたプレイヤーが遊んだモードを取り出す
  List<String> get _modes {
    if (_selectedPlayer == null) return [];
    return _records
        .where((r) => r.playerName == _selectedPlayer)
        .map((r) => r.mode)
        .toSet()
        .toList();
  }

  // --- 追加：効率を計算する共通メソッド ---
  double _calculateEfficiency(GameRecord r) {
    List<String> parts = r.time.split(':');
    if (parts.length != 2) return 0; // フォーマットエラー対策

    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    double totalSec = minutes * 60.0 + seconds;

    if (totalSec < 1) return 0; // 0除算エラー防止
    return double.parse((r.score / totalSec).toStringAsFixed(3));
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // プレイヤー選択
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPlayer,
              hint: const Text("プレイヤー"),
              items: _players
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPlayer = val;
                  _selectedMode = null; // プレイヤーが変わったらモードはリセット
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          // モード選択
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedMode,
              hint: const Text("モード"),
              items: _modes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMode = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final data = _getChartData();

    if (data.isEmpty) {
      return const Center(child: Text("データが足りません"));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final r = data[i];
      double efficiency = _calculateEfficiency(r);
      spots.add(FlSpot(i.toDouble(), efficiency));
    }

    final barData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.blue,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.1),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 20, left: 10, bottom: 20),
      child: LineChart(
        LineChartData(
          showingTooltipIndicators: spots.asMap().entries.map((entry) {
            return ShowingTooltipIndicators([
              LineBarSpot(barData, 0, entry.value),
            ]);
          }).toList(),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(3), // ここで強制的に3桁にする
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45, // 3桁だと文字幅を取るので、少し広げる
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(3), // ここで強制的に3桁にする
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    DateTime d = data[index].date;
                    return Text(
                      "${d.month}/${d.day}",
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text("");
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          lineBarsData: [barData],
        ),
      ),
    );
  }

  // 3. グラフ用のデータを作成する
  List<GameRecord> _getChartData() {
    if (_selectedPlayer == null || _selectedMode == null) return [];

    var filtered = _records
        .where(
          (r) => r.playerName == _selectedPlayer && r.mode == _selectedMode,
        )
        .toList();

    Map<String, GameRecord> dailyBest = {};

    for (var r in filtered) {
      String dateKey = "${r.date.year}-${r.date.month}-${r.date.day}";

      // 共通メソッドを使用
      double currentEfficiency = _calculateEfficiency(r);

      if (!dailyBest.containsKey(dateKey)) {
        dailyBest[dateKey] = r;
      } else {
        // 既存の記録の効率を計算
        var best = dailyBest[dateKey]!;
        double bestEff = _calculateEfficiency(best);

        // より効率が高い場合は上書きする
        if (currentEfficiency > bestEff) {
          dailyBest[dateKey] = r;
        }
        // 【任意】効率が全く同じ場合は、スコア単体が高い方を優先するなどのルールを追加できます
        else if (currentEfficiency == bestEff && r.score > best.score) {
          dailyBest[dateKey] = r;
        }
      }
    }

    var result = dailyBest.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date)); // X軸の描画のために古い順に並べる
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('練習記録'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: _records.isEmpty
                ? const Center(child: Text("まだ記録がありません"))
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.stars,
                            color: Colors.orange,
                          ),
                          title: Text(
                            "${record.mode} (${record.score}/100) - ${record.playerName}",
                          ),
                          subtitle: Text(
                            "${record.date.year}/${record.date.month}/${record.date.day} ${record.date.hour}:${record.date.minute}",
                          ),
                          trailing: Text(
                            record.time,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                      top: 10,
                      bottom: 36,
                    ),
                    color: Colors.grey.shade100,
                    child: Center(
                      child: _selectedMode == null
                          ? const Text("プレイヤーとモードを選択してください")
                          : _buildLineChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
