import 'package:flutter/material.dart';
import 'Timer.dart';
import 'ResultScreen.dart';

class TemplateMultiplication extends StatelessWidget {
  final int rowMin, rowMax, colMin, colMax;
  final String mode;

  const TemplateMultiplication({
    super.key,
    required this.rowMin,
    required this.rowMax,
    required this.colMin,
    required this.colMax,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(mode),
      ),
      body: Center(
        child: TemplateMultiplicationBrain(
          rowMin: rowMin,
          rowMax: rowMax,
          colMin: colMin,
          colMax: colMax,
          mode: mode,
        ),
      ),
    );
  }
}

class TemplateMultiplicationBrain extends StatefulWidget {
  final int rowMin, rowMax, colMin, colMax;
  final String mode;
  const TemplateMultiplicationBrain({
    super.key,
    required this.rowMin,
    required this.rowMax,
    required this.colMin,
    required this.colMax,
    required this.mode,
  });

  @override
  State<TemplateMultiplicationBrain> createState() =>
      _TemplateMultiplicationBrainState();
}

class _TemplateMultiplicationBrainState
    extends State<TemplateMultiplicationBrain> {
  late List<int> rowNumbers;
  late List<int> colNumbers;
  bool _showAnswers = false;
  bool _isStarted = false;
  bool _isFinished = false;
  String _timeDisplay = "00:00";

  final CalculationTimer _timer = CalculationTimer();
  // ここで widget.rowMin のようにして値にアクセスできます
  @override
  void initState() {
    super.initState();
    _generateNumbers();
    _timer.onTick = (newTime) {
      setState(() {
        _timeDisplay = newTime;
      });
    };
  }

  @override
  void dispose() {
    _timer.stop();
    super.dispose();
  }

  void _onResultPressed() {
    String resTime = _timeDisplay;
    // ここで結果画面に遷移したり、ダイアログを出したりします
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          mode: widget.mode,
          timeTaken: Duration(
            seconds:
                int.parse(resTime.split(':')[0]) * 60 +
                int.parse(resTime.split(':')[1]),
          ),
        ),
      ),
    );
    // 例: Navigator.push(...) など
  }

  void _generateNumbers() {
    List<int> rowRange = [
      for (int i = widget.rowMin; i <= widget.rowMax; i++) i,
    ];
    List<int> colRange = [
      for (int i = widget.colMin; i <= widget.colMax; i++) i,
    ];
    rowRange.shuffle();
    colRange.shuffle();
    rowNumbers = rowRange.take(10).toList();
    colNumbers = colRange.take(10).toList();
  }

  Widget _buildCalculationUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey), // 枠線
            children: [
              // --- 1行目（横の数字出し） ---
              TableRow(
                children: [
                  const Center(),
                  for (var n in rowNumbers)
                    Container(
                      height: 40,
                      color: Colors.blue.shade50,
                      child: Center(
                        child: Text(
                          "$n",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              // --- 2行目以降（縦の数字 + 入力欄） ---
              for (int i = 0; i < 10; i++)
                TableRow(
                  children: [
                    // 左端の縦数字
                    Container(
                      height: 40,
                      color: Colors.orange.shade50,
                      child: Center(
                        child: Text(
                          "${colNumbers[i]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // 入力欄 10個
                    for (int j = 0; j < 10; j++)
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          _showAnswers
                              ? "${rowNumbers[j] * colNumbers[i]}"
                              : "",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 164, 24, 24),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text("タイム: $_timeDisplay", style: TextStyle(fontSize: 24)),
          if (!_isStarted)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isStarted = true;
                  _timer.start();
                });
              },
              label: Text("スタート"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
              ),
            )
          else if (_isStarted && !_isFinished)
            ElevatedButton.icon(
              onPressed: _showAnswers
                  ? null
                  : () {
                      setState(() {
                        _timer.stop();
                        _showAnswers = true;
                        _isFinished = true;
                      });
                    },
              label: Text("フィニッシュ&答え合わせ"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                backgroundColor: Colors.redAccent,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _onResultPressed,
              label: Text("結果入力へ"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCalculationUI();
  }
}
