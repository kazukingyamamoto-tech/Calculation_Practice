import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/GameRecord.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<GameRecord> _records = [];
  String _scoreMethod = '秒間正解数';
  bool _isDeleteMode = false;
  final Set<int> _selectedRecordIndices = {};

  @override
  void initState() {
    super.initState();
    _loadRecords(); // 画面が開いたら読み込む
    _loadSettings(); // 設定を読み込む
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scoreMethod = prefs.getString('scoreMethod') ?? '秒間正解数';
    });
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

  Future<void> _saveRecordsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_records.map((r) => r.toMap()).toList());
    await prefs.setString('game_records', jsonString);
  }

  Future<void> _onDeleteButtonPressed() async {
    if (!_isDeleteMode) {
      setState(() {
        _isDeleteMode = true;
        _selectedRecordIndices.clear();
      });
      return;
    }

    if (_selectedRecordIndices.isEmpty) {
      setState(() {
        _isDeleteMode = false;
      });
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("削除しても良いですか？"),
        content: const Text("選択した記録を削除します。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("キャンセル"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("削除する"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      final remaining = <GameRecord>[];
      for (int i = 0; i < _records.length; i++) {
        if (!_selectedRecordIndices.contains(i)) {
          remaining.add(_records[i]);
        }
      }
      _records = remaining;
      _selectedRecordIndices.clear();
      _isDeleteMode = false;
    });

    await _saveRecordsToStorage();
    await _loadRecords();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("選択した記録を削除しました")));
  }

  Future<void> _exportRecords() async {
    if (_records.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("記録がありません")));
      return;
    }

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("端末に保存しますか？"),
          content: const Text("保存先フォルダを選択してエクスポートします。"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("保存する"),
            ),
          ],
        ),
      );

      if (shouldSave != true) {
        return;
      }

      final jsonString = jsonEncode(_records.map((r) => r.toMap()).toList());
      final folderPath = await getDirectoryPath();
      if (folderPath == null) {
        return;
      }

      final file = File(
        '$folderPath${Platform.pathSeparator}game_records.json',
      );
      await file.writeAsString(jsonString);
      if (!mounted) return;
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("共有しますか？"),
          content: const Text("エクスポートした記録を他のアプリで共有できます。"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("しない"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("共有する"),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (shouldShare == true) {
        await Share.shareXFiles([
          XFile(file.path, mimeType: 'application/json'),
        ]);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("エクスポートしました")));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("エクスポートに失敗しました")));
    }
  }

  Future<void> _importRecords() async {
    try {
      final typeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);
      final picked = await openFile(acceptedTypeGroups: [typeGroup]);
      if (picked == null) {
        return;
      }

      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("インポートしますか？"),
          content: const Text("選択したファイルの記録を追加します。"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("インポート"),
            ),
          ],
        ),
      );

      if (shouldImport != true) {
        return;
      }

      final content = await picked.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        throw const FormatException("Invalid file format");
      }

      final importedRecords = decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => GameRecord.fromMap(item))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString('game_records');
      final List<dynamic> combined = existingJson == null
          ? []
          : jsonDecode(existingJson) as List<dynamic>;

      for (final record in importedRecords) {
        combined.add(record.toMap());
      }

      await prefs.setString('game_records', jsonEncode(combined));
      await _loadRecords();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("インポートしました")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("インポートに失敗しました")));
    }
  }

  Widget _buildExportImportButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _exportRecords,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F1F1),
                side: const BorderSide(color: Color(0xFF544275), width: 2),
                foregroundColor: const Color(0xFF544275),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('記録をエクスポート'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _importRecords,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F1F1),
                side: const BorderSide(color: Color(0xFF544275), width: 2),
                foregroundColor: const Color(0xFF544275),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('記録をインポート'),
            ),
          ),
        ],
      ),
    );
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
    if (_scoreMethod == '正解数') {
      return r.score.toDouble();
    }

    List<String> parts = r.time.split(':');
    if (parts.length != 2) return 0; // フォーマットエラー対策

    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    double totalSec = minutes * 60.0 + seconds;

    if (_scoreMethod == 'クリア時間') {
      return totalSec;
    }

    if (totalSec < 1) return 0; // 0除算エラー防止

    if (_scoreMethod == '秒間正解数') {
      return double.parse((r.score / totalSec).toStringAsFixed(2));
    }

    return r.score.toDouble(); // デフォルト
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
              hint: const Text(
                "プレイヤー",
                style: TextStyle(color: Color(0xFF544275)),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF544275)),
              style: const TextStyle(
                color: Color(0xFF544275),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
              hint: const Text(
                "モード",
                style: TextStyle(color: Color(0xFF544275)),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF544275)),
              style: const TextStyle(
                color: Color(0xFF544275),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
    final dailyBest = _getChartData();

    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month, now.day);
    DateTime startDate = endDate.subtract(const Duration(days: 6));

    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime targetDate = startDate.add(Duration(days: i));
      String dateKey =
          "${targetDate.year}-${targetDate.month}-${targetDate.day}";

      if (dailyBest.containsKey(dateKey)) {
        double efficiency = _calculateEfficiency(dailyBest[dateKey]!);
        spots.add(FlSpot(i.toDouble(), efficiency));
      } else {
        spots.add(FlSpot.nullSpot);
      }
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
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: _scoreMethod == '正解数' ? 100 : null,
          showingTooltipIndicators: spots
              .asMap()
              .entries
              .map((entry) {
                if (entry.value == FlSpot.nullSpot) return null;
                return ShowingTooltipIndicators([
                  LineBarSpot(barData, 0, entry.value),
                ]);
              })
              .where((e) => e != null)
              .cast<ShowingTooltipIndicators>()
              .toList(),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    _scoreMethod == '秒間正解数'
                        ? spot.y.toStringAsFixed(2)
                        : spot.y.toInt().toString(), // 秒間正解数は小数第1位、その他は整数
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
                reservedSize: 35, // 1桁のために少し幅を狭める
                getTitlesWidget: (value, meta) {
                  return Text(
                    _scoreMethod == '秒間正解数'
                        ? value.toStringAsFixed(2)
                        : value.toInt().toString(), // 秒間正解数は小数第1位、その他は整数
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < 7) {
                    DateTime d = startDate.add(Duration(days: index));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${d.month}/${d.day}",
                        style: const TextStyle(fontSize: 10),
                      ),
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
  Map<String, GameRecord> _getChartData() {
    if (_selectedPlayer == null || _selectedMode == null) return {};

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

        bool isBetter = _scoreMethod == 'クリア時間'
            ? currentEfficiency <
                  bestEff // 時間は少ない方が良い
            : currentEfficiency > bestEff; // その他は高い方が良い

        // より効率が高い場合は上書きする
        if (isBetter) {
          dailyBest[dateKey] = r;
        }
        // 【任意】効率が全く同じ場合は、スコア単体が高い方を優先するなどのルールを追加できます
        else if (currentEfficiency == bestEff && r.score > best.score) {
          dailyBest[dateKey] = r;
        }
      }
    }

    return dailyBest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          '練習記録',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF544275),
          ),
        ),
        elevation: 0,
        foregroundColor: const Color(0xFF544275),
        iconTheme: const IconThemeData(color: Color(0xFF544275)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCAB6F1), Color(0xFFFBE0D1)],
            stops: [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildExportImportButtons(),
              Expanded(
                flex: 6,
                child: _records.isEmpty
                    ? const Center(child: Text("まだ記録がありません"))
                    : ListView.builder(
                        itemCount: _records.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _records.length) {
                            if (_records.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              child: OutlinedButton(
                                onPressed: _onDeleteButtonPressed,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F1F1),
                                  side: const BorderSide(
                                    color: Color(0xFF544275),
                                    width: 2,
                                  ),
                                  foregroundColor: const Color(0xFF544275),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  _isDeleteMode
                                      ? "削除する(${_selectedRecordIndices.length})"
                                      : "削除する",
                                ),
                              ),
                            );
                          }

                          final record = _records[index];
                          final isSelected = _selectedRecordIndices.contains(
                            index,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFF544275),
                                width: 1.0, // うっすらとした細さに変更
                              ),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: const Icon(
                                Icons.stars,
                                color: Colors.orange,
                              ),
                              title: Text(
                                "${record.mode}\n${record.playerName} (${record.score}/100)",
                              ),
                              subtitle: Text(
                                "${record.date.year}/${record.date.month}/${record.date.day} ${record.date.hour}:${record.date.minute}  ${record.time}",
                              ),
                              trailing: _isDeleteMode
                                  ? Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: const Color(0xFF544275),
                                    )
                                  : Text(
                                      record.time,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              onTap: _isDeleteMode
                                  ? () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedRecordIndices.remove(index);
                                        } else {
                                          _selectedRecordIndices.add(index);
                                        }
                                      });
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      _buildFilters(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 10,
                            bottom: 30,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FA), // 少しだけ紫がかった薄いグレー
                            borderRadius: BorderRadius.circular(16),
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
