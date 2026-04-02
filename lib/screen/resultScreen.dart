import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../logic/GameRecord.dart';

class ResultScreen extends StatefulWidget {
  final Duration timeTaken;
  final String mode;
  final int? fixedScore;

  const ResultScreen({
    super.key,
    required this.timeTaken,
    required this.mode,
    this.fixedScore,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // --- 入力用のリスト群 ---
  final List<TextEditingController> _scoreControllers = [];
  final List<TextEditingController> _nameControllers = [];

  // 各プレイヤーが「既存」を選んでいるか「新規」を選んでいるかを管理するリスト
  final List<String?> _selectedPlayers = [];
  final List<bool> _isNewPlayers = [];

  // これまでに保存されているプレイヤー名のリスト
  List<String> _existingPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPlayers(); // 最初に過去のプレイヤーを読み込む
  }

  @override
  void dispose() {
    for (var c in _scoreControllers) {
      c.dispose();
    }
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // 1. 過去のプレイヤー名を読み込む
  Future<void> _loadExistingPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('game_records');

    if (recordsJson != null) {
      final List<dynamic> decodedList = jsonDecode(recordsJson);
      final List<GameRecord> records = decodedList
          .map((item) => GameRecord.fromMap(item))
          .toList();

      setState(() {
        _existingPlayers = records.map((r) => r.playerName).toSet().toList();
      });
    }
    // 読み込みが終わったら、初期状態で1人目の入力欄を作る
    _addPlayer();
  }

  // プレイヤーを追加するメソッド
  void _addPlayer() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _scoreControllers.add(
        TextEditingController(text: widget.fixedScore?.toString() ?? ""),
      );

      // 過去の記録があれば一番上の人を選択、なければ強制的に「新規」モードにする
      if (_existingPlayers.isNotEmpty) {
        _selectedPlayers.add(_existingPlayers.first);
        _isNewPlayers.add(false);
      } else {
        _selectedPlayers.add('NEW_PLAYER');
        _isNewPlayers.add(true);
      }
    });
  }

  // プレイヤーを削除するメソッド
  void _removePlayer(int index) {
    if (_scoreControllers.length > 1) {
      setState(() {
        _nameControllers[index].dispose();
        _scoreControllers[index].dispose();

        // すべてのリストから該当インデックスを削除する
        _nameControllers.removeAt(index);
        _scoreControllers.removeAt(index);
        _selectedPlayers.removeAt(index);
        _isNewPlayers.removeAt(index);
      });
    }
  }

  Future<void> _saveAllToStorage(List<GameRecord> newRecords) async {
    final prefs = await SharedPreferences.getInstance();

    final String? existingData = prefs.getString('game_records');
    List<dynamic> listToSave = [];

    if (existingData != null) {
      listToSave = jsonDecode(existingData);
    }

    for (var record in newRecords) {
      listToSave.add(record.toMap());
    }

    await prefs.setString('game_records', jsonEncode(listToSave));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('結果入力'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'タイム: ${widget.timeTaken.inMinutes}:${(widget.timeTaken.inSeconds % 60).toString().padLeft(2, "0")}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (widget.fixedScore != null)
              Text(
                '手入力モードの採点結果を自動入力しています（${widget.fixedScore}/100）',
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (widget.fixedScore != null) const SizedBox(height: 8),

            // プレイヤーカードは固定サイズコンテナ内でスクロール表示
            SizedBox(
              height: 390,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _scoreControllers.isEmpty
                    ? const Center(
                        child: Text(
                          'プレイヤーを追加してください',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: _scoreControllers.length,
                          itemBuilder: (context, index) {
                            return _buildPlayerInputField(index);
                          },
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // プレイヤー追加ボタン (手入力モード時は非表示)
            if (widget.fixedScore == null) ...[
              ElevatedButton.icon(
                onPressed: _addPlayer,
                icon: const Icon(Icons.person_add),
                label: const Text('プレイヤーを追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(height: 30),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      SizedBox(width: 4),
                      Text('戻る'),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<GameRecord> newRecords = [];
                    for (int i = 0; i < _scoreControllers.length; i++) {
                      int score =
                          widget.fixedScore ??
                          (int.tryParse(_scoreControllers[i].text) ?? 0);

                      // ★新規か既存かで保存する名前を切り替える
                      String finalPlayerName = _isNewPlayers[i]
                          ? _nameControllers[i].text
                          : _selectedPlayers[i] ?? "名無し";

                      // 名前が空欄だったらスキップする（またはエラーを出す）などの処理も可能
                      if (finalPlayerName.trim().isEmpty)
                        finalPlayerName = "名無し";

                      newRecords.add(
                        GameRecord(
                          playerName: finalPlayerName,
                          date: DateTime.now(),
                          time:
                              "${widget.timeTaken.inMinutes.toString().padLeft(2, "0")}:${(widget.timeTaken.inSeconds % 60).toString().padLeft(2, "0")}",
                          mode: widget.mode,
                          score: score,
                        ),
                      );
                    }

                    await _saveAllToStorage(newRecords);

                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text('保存してホームへ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1人分の入力フィールドを作る部品
  Widget _buildPlayerInputField(int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                // ドロップダウン
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPlayers[index],
                    decoration: const InputDecoration(labelText: "プレイヤー選択"),
                    items: [
                      ..._existingPlayers.map(
                        (name) =>
                            DropdownMenuItem(value: name, child: Text(name)),
                      ),
                      const DropdownMenuItem(
                        value: 'NEW_PLAYER',
                        child: Text(
                          '＋ 新規プレイヤーを入力',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedPlayers[index] = val;
                        // 新規プレイヤーが選ばれたらフラグを立てる
                        _isNewPlayers[index] = (val == 'NEW_PLAYER');
                      });
                    },
                  ),
                ),
                if (_scoreControllers.length > 1) // 1人だけの時は消せない
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePlayer(index),
                  ),
              ],
            ),

            // ★新規の時だけ名前入力欄を表示
            if (_isNewPlayers[index]) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _nameControllers[index],
                decoration: const InputDecoration(
                  labelText: "新しいプレイヤー名",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                const Text("正解数: "),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _scoreControllers[index],
                    readOnly: widget.fixedScore != null,
                    enableInteractiveSelection: widget.fixedScore == null,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "正解数を入力してください",
                      suffixText: "/ 100",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
