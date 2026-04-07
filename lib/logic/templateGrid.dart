import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'timer.dart';
import '../screen/resultScreen.dart';
import 'calculateAnswerLogic.dart';
import 'grid_pdf_logic.dart';

class TemplateMultiplication extends StatelessWidget {
  final int rowMin, rowMax, colMin, colMax;
  final String mode;
  final bool manualInputMode;

  const TemplateMultiplication({
    super.key,
    required this.rowMin,
    required this.rowMax,
    required this.colMin,
    required this.colMax,
    required this.mode,
    this.manualInputMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return TemplateMultiplicationBrain(
      rowMin: rowMin,
      rowMax: rowMax,
      colMin: colMin,
      colMax: colMax,
      mode: mode,
      manualInputMode: manualInputMode,
      calculateAnswer: calculateAnswer,
    );
  }
}

class TemplateMultiplicationBrain extends StatefulWidget {
  final int rowMin, rowMax, colMin, colMax;
  final String mode;
  final bool manualInputMode;
  // ★ 修正：int ではなく AxisItem を受け取る関数にする
  final String Function(AxisItem, AxisItem, String) calculateAnswer;

  const TemplateMultiplicationBrain({
    super.key,
    required this.rowMin,
    required this.rowMax,
    required this.colMin,
    required this.colMax,
    required this.mode,
    required this.manualInputMode,
    required this.calculateAnswer,
  });

  @override
  State<TemplateMultiplicationBrain> createState() =>
      _TemplateMultiplicationBrainState();
}

class _TemplateMultiplicationBrainState
    extends State<TemplateMultiplicationBrain> {
  // ★ 修正：int ではなく AxisItem のリストにする
  late List<AxisItem> rowNumbers;
  late List<AxisItem> colNumbers;

  bool _showAnswers = false;
  bool _isStarted = false;
  bool _isFinished = false;
  String _timeDisplay = "00:00";
  int _score = 0;
  int _selectedRow = 0;
  int _selectedCol = 0;
  final TransformationController _manualPanController =
      TransformationController();
  final GlobalKey _manualViewportKey = GlobalKey();
  final GlobalKey _timePanelKey = GlobalKey();
  double _timePanelHeight = 0;

  late final List<List<String>> _manualInputs;
  late final List<List<bool?>> _cellCorrectness;

  final CalculationTimer _timer = CalculationTimer();

  bool _isPhoneKeypad = false; // ★追加：キーパッドの配置を保持

  @override
  void initState() {
    super.initState();
    _loadSettings(); // ★追加：設定を読み込む
    _generateNumbers();
    _timer.onTick = (newTime) {
      setState(() {
        _timeDisplay = newTime;
      });
    };

    if (widget.manualInputMode) {
      _manualInputs = List.generate(10, (_) => List.generate(10, (_) => ""));
      _cellCorrectness = List.generate(
        10,
        (_) => List.generate(10, (_) => null),
      );
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPhoneKeypad = prefs.getBool('isPhoneKeypad') ?? false;
      });
    }
  }

  @override
  void dispose() {
    _manualPanController.dispose();
    _timer.stop();
    super.dispose();
  }

  void _onResultPressed() {
    String resTime = _timeDisplay;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          mode: widget.mode,
          fixedScore: widget.manualInputMode ? _score : null,
          timeTaken: Duration(
            seconds:
                int.parse(resTime.split(':')[0]) * 60 +
                int.parse(resTime.split(':')[1]),
          ),
        ),
      ),
    );
  }

  Future<void> _onPrintPressed() async {
    try {
      await printGridAsPdf(
        mode: widget.mode,
        rowNumbers: rowNumbers,
        colNumbers: colNumbers,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('印刷に失敗しました')));
    }
  }

  void _generateNumbers() {
    final random = Random(); // ランダム生成器

    // 1. 万が一 Min と Max が逆でもエラーにならないよう、安全に範囲を決める
    int rMin = min(widget.rowMin, widget.rowMax);
    int rMax = max(widget.rowMin, widget.rowMax);
    int cMin = min(widget.colMin, widget.colMax);
    int cMax = max(widget.colMin, widget.colMax);

    // （※ min, max を使うために、ファイルの先頭に import 'dart:math'; が必要です）

    List<int> rowRange = [for (int i = rMin; i <= rMax; i++) i];
    List<int> colRange = [for (int i = cMin; i <= cMax; i++) i];

    List<int> selectedRows = [];
    List<int> selectedCols = [];

    // 2. 横の数字を10個選ぶ
    if (rowRange.length >= 10) {
      // 選択肢が10個以上あるなら、シャッフルして被りなしで10個取る
      rowRange.shuffle();
      selectedRows = rowRange.take(10).toList();
    } else {
      // 選択肢が少ない（1桁など）場合は、重複を許してランダムに10個選ぶ
      selectedRows = List.generate(
        10,
        (_) => rowRange[random.nextInt(rowRange.length)],
      );
    }

    // 3. 縦の数字を10個選ぶ
    if (colRange.length >= 10) {
      colRange.shuffle();
      selectedCols = colRange.take(10).toList();
    } else {
      selectedCols = List.generate(
        10,
        (_) => colRange[random.nextInt(colRange.length)],
      );
    }

    // 4. AxisItem（専用クラス）に変換する
    rowNumbers = selectedRows.map((n) {
      String op = "";
      if (widget.mode.contains("循環")) {
        op = "^"; // 累乗のマーク
      }

      if (widget.mode == "少数の掛け算") {
        return AxisItem(
          number: n,
          operator: op,
          displayOverride: (n / 10).toStringAsFixed(1),
        );
      }

      return AxisItem(number: n, operator: op); // 横軸は記号なし
    }).toList();

    colNumbers = selectedCols.map((n) {
      String op = "";
      if (widget.mode.contains("割り算")) {
        op = "÷"; // 割り算のマーク
      }
      if (widget.mode.contains("ミックス")) {
        op = random.nextBool() ? "×" : "÷";
      }
      return AxisItem(number: n, operator: op);
    }).toList();
  }

  int _gradeManualAnswers() {
    int correct = 0;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        final expected = widget.calculateAnswer(
          rowNumbers[j],
          colNumbers[i],
          widget.mode,
        );
        final actual = _manualInputs[i][j].trim();
        final isCorrect = actual == expected;
        _cellCorrectness[i][j] = isCorrect;
        if (isCorrect) {
          correct++;
        }
      }
    }
    return correct;
  }

  Color _cellColorFor(int row, int col) {
    if (!widget.manualInputMode || !_showAnswers) {
      return Colors.white;
    }
    final isCorrect = _cellCorrectness[row][col];
    if (isCorrect == true) {
      return Colors.green.shade200;
    }
    return Colors.red.shade200;
  }

  BoxDecoration _cellDecorationFor(int row, int col) {
    final isSelected =
        widget.manualInputMode &&
        !_showAnswers &&
        row == _selectedRow &&
        col == _selectedCol;

    return BoxDecoration(
      color: _cellColorFor(row, col),
      border: Border.all(
        color: isSelected ? Colors.blueAccent : Colors.transparent,
        width: isSelected ? 2 : 0,
      ),
    );
  }

  bool get _isManualSelectionActive {
    return widget.manualInputMode &&
        _isStarted &&
        !_showAnswers &&
        !_isFinished;
  }

  Color _rowAxisCellColor(int col) {
    if (_isManualSelectionActive && col == _selectedCol) {
      return Colors.blue.shade200;
    }
    return Colors.blue.shade50;
  }

  Color _colAxisCellColor(int row) {
    if (_isManualSelectionActive && row == _selectedRow) {
      return Colors.orange.shade200;
    }
    return Colors.orange.shade50;
  }

  void _selectCell(int row, int col) {
    if (!widget.manualInputMode || _showAnswers) {
      return;
    }
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
    _ensureSelectedCellVisible();
  }

  void _appendManualInput(String value) {
    if (!widget.manualInputMode || _showAnswers) {
      return;
    }

    setState(() {
      final current = _manualInputs[_selectedRow][_selectedCol];
      if (current.length >= 8) {
        return;
      }

      if ((value == '.' || value == '/') && current.contains(value)) {
        return;
      }

      if (value == '.' && current.isEmpty) {
        _manualInputs[_selectedRow][_selectedCol] = '0.';
        return;
      }

      if (value == '/' && current.isEmpty) {
        return;
      }

      _manualInputs[_selectedRow][_selectedCol] = '$current$value';
    });
  }

  void _deleteManualInput() {
    if (!widget.manualInputMode || _showAnswers) {
      return;
    }

    setState(() {
      _manualInputs[_selectedRow][_selectedCol] = '';
    });
  }

  void _moveSelectedCell(int dRow, int dCol) {
    if (!widget.manualInputMode || _showAnswers) {
      return;
    }

    setState(() {
      int nextRow = _selectedRow;
      int nextCol = _selectedCol;

      // Left key
      if (dCol == -1 && dRow == 0) {
        if (_selectedCol > 0) {
          nextCol = _selectedCol - 1;
        } else if (_selectedRow > 0) {
          nextRow = _selectedRow - 1;
          nextCol = 9;
        }
      }

      // Right key
      if (dCol == 1 && dRow == 0) {
        if (_selectedCol < 9) {
          nextCol = _selectedCol + 1;
        } else if (_selectedRow < 9) {
          nextRow = _selectedRow + 1;
          nextCol = 0;
        }
      }

      // Up key
      if (dRow == -1 && dCol == 0) {
        if (_selectedRow > 0) {
          nextRow = _selectedRow - 1;
        } else if (_selectedCol > 0) {
          nextRow = 9;
          nextCol = _selectedCol - 1;
        }
      }

      // Down key
      if (dRow == 1 && dCol == 0) {
        if (_selectedRow < 9) {
          nextRow = _selectedRow + 1;
        } else if (_selectedCol < 9) {
          nextRow = 0;
          nextCol = _selectedCol + 1;
        }
      }

      _selectedRow = nextRow;
      _selectedCol = nextCol;
    });
    _ensureSelectedCellVisible();
  }

  void _ensureSelectedCellVisible() {
    const double cellSize = 56;
    const double totalSize = cellSize * 10;
    const double headerSize = cellSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _manualViewportKey.currentContext;
      if (context == null) {
        return;
      }

      final viewportSize = context.size;
      if (viewportSize == null) {
        return;
      }

      final targetCenterX = (_selectedCol * cellSize) + (cellSize / 2);
      final targetCenterY = (_selectedRow * cellSize) + (cellSize / 2);

      final viewportW = viewportSize.width - headerSize;
      final viewportH = viewportSize.height - headerSize;

      double tx = (viewportW / 2) - targetCenterX;
      double ty = (viewportH / 2) - targetCenterY;

      final minTx = viewportW - totalSize;
      final minTy = viewportH - totalSize;

      tx = tx.clamp(minTx, 0.0);
      ty = ty.clamp(minTy, 0.0);

      _manualPanController.value = Matrix4.identity()..translate(tx, ty);
    });
  }

  double _manualKeypadButtonHeight(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.065;
  }

  double _estimateManualKeypadHeight(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final buttonHeight = _manualKeypadButtonHeight(context);

    const double containerPadding = 16;
    const double containerMargin = 8;
    const double verticalGaps = 7 + 13 + 6 + 6 + 8;

    final double titleHeight = (20 * textScale) + 6;
    final double subtitleHeight = (15 * textScale) + 4;

    return containerMargin +
        containerPadding +
        titleHeight +
        subtitleHeight +
        verticalGaps +
        (buttonHeight * 4);
  }

  void _updateTimePanelHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _timePanelKey.currentContext;
      if (context == null) {
        return;
      }

      final newHeight = context.size?.height ?? 0;
      if (newHeight <= 0) {
        return;
      }

      if ((newHeight - _timePanelHeight).abs() > 0.5 && mounted) {
        setState(() {
          _timePanelHeight = newHeight;
        });
      }
    });
  }

  Widget _buildKeyButton({
    String? text,
    IconData? icon,
    int flex = 1,
    double fontSize = 20,
    required VoidCallback onTap,
  }) {
    final double buttonHeight = _manualKeypadButtonHeight(context);

    return Expanded(
      flex: flex,
      child: SizedBox(
        height: buttonHeight, // Pixel 8aの比率 (約60px) に基づく
        child: FilledButton(
          onPressed: _showAnswers ? null : onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF544275), // 濃い紫色で読みやすく
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey.shade500,
            padding: EdgeInsets.zero,
            side: const BorderSide(color: Color(0xFF544275), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 24)
              : Text(
                  text ?? '',
                  style: TextStyle(
                    fontSize: fontSize + 2, // サイズを少し大きく
                    fontWeight: FontWeight.w900, // より太く
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildManualKeypad() {
    final extraInputKey =
        (widget.mode == "少数の掛け算" || widget.mode.contains("割り算の少数")) ? '.' : '/';

    // _isPhoneKeypad の設定に応じてキーパットの行を切り替える
    final List<Widget> keypadTopRow = _isPhoneKeypad
        ? [
            _buildKeyButton(text: '1', onTap: () => _appendManualInput('1')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '2', onTap: () => _appendManualInput('2')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '3', onTap: () => _appendManualInput('3')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '0', onTap: () => _appendManualInput('0')),
          ]
        : [
            _buildKeyButton(text: '7', onTap: () => _appendManualInput('7')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '8', onTap: () => _appendManualInput('8')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '9', onTap: () => _appendManualInput('9')),
            const SizedBox(width: 6),
            _buildKeyButton(
              text: '削除',
              fontSize: 14,
              onTap: _deleteManualInput,
            ),
          ];

    final List<Widget> keypadBottomRow = _isPhoneKeypad
        ? [
            _buildKeyButton(text: '7', onTap: () => _appendManualInput('7')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '8', onTap: () => _appendManualInput('8')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '9', onTap: () => _appendManualInput('9')),
            const SizedBox(width: 6),
            _buildKeyButton(
              text: '削除',
              fontSize: 14,
              onTap: _deleteManualInput,
            ),
          ]
        : [
            _buildKeyButton(text: '1', onTap: () => _appendManualInput('1')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '2', onTap: () => _appendManualInput('2')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '3', onTap: () => _appendManualInput('3')),
            const SizedBox(width: 6),
            _buildKeyButton(text: '0', onTap: () => _appendManualInput('0')),
          ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'セルをタップして入力',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 7),
          Text(
            '選択中セル: ${_selectedRow + 1}行 ${_selectedCol + 1}列',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: keypadTopRow,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKeyButton(text: '4', onTap: () => _appendManualInput('4')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '5', onTap: () => _appendManualInput('5')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '6', onTap: () => _appendManualInput('6')),
              const SizedBox(width: 6),
              _buildKeyButton(
                text: extraInputKey,
                onTap: () => _appendManualInput(extraInputKey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: keypadBottomRow,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKeyButton(
                icon: Icons.keyboard_arrow_left,
                onTap: () => _moveSelectedCell(0, -1),
              ),
              const SizedBox(width: 6),
              _buildKeyButton(
                icon: Icons.keyboard_arrow_up,
                onTap: () => _moveSelectedCell(-1, 0),
              ),
              const SizedBox(width: 6),
              _buildKeyButton(
                icon: Icons.keyboard_arrow_down,
                onTap: () => _moveSelectedCell(1, 0),
              ),
              const SizedBox(width: 6),
              _buildKeyButton(
                icon: Icons.keyboard_arrow_right,
                onTap: () => _moveSelectedCell(0, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(int row, int col) {
    if (widget.manualInputMode) {
      return GestureDetector(
        onTap: () => _selectCell(row, col),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _manualInputs[row][col],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _showAnswers ? 14 : 28, // 答え合わせ中は小さく
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        _showAnswers
            ? widget.calculateAnswer(
                rowNumbers[col],
                colNumbers[row],
                widget.mode,
              )
            : "",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 164, 24, 24),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildAxisText(String text, {double fontSize = 28}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ),
    );
  }

  Widget _buildManualScrollableGrid({
    double? height,
    required bool showOverview,
  }) {
    const double cellSize = 56;
    const double headerSize = cellSize;
    final bodySize = cellSize * 10;

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final gridViewportWidth = (constraints.maxWidth - headerSize).clamp(
          0.0,
          double.infinity,
        );
        final gridViewportHeight = (constraints.maxHeight - headerSize).clamp(
          0.0,
          double.infinity,
        );
        final overviewScale = min(
          gridViewportWidth / bodySize,
          gridViewportHeight / bodySize,
        ).clamp(0.35, 1.0);

        final minPanX = min(gridViewportWidth - bodySize, 0.0);
        final minPanY = min(gridViewportHeight - bodySize, 0.0);

        return Container(
          key: _manualViewportKey,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // 左上の空白（#）部分
              Positioned(
                left: 0,
                top: 0,
                width: headerSize,
                height: headerSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade500),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // X軸（上部の横並び数字）
              Positioned(
                left: headerSize,
                top: 0,
                right: 0,
                height: headerSize,
                child: AnimatedBuilder(
                  animation: _manualPanController,
                  builder: (context, _) {
                    final m = _manualPanController.value.storage;
                    final panX = showOverview ? 0.0 : m[12].clamp(minPanX, 0.0);
                    return ClipRect(
                      child: Transform.translate(
                        offset: Offset(panX, 0),
                        // ★ 修正：OverflowBoxを追加し、親の幅制約を無視して描画させる
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Transform.scale(
                            alignment: Alignment.centerLeft,
                            scale: showOverview ? overviewScale : 1.0,
                            child: SizedBox(
                              width: bodySize,
                              child: Row(
                                children: [
                                  for (int c = 0; c < 10; c++)
                                    Container(
                                      width: cellSize,
                                      height: headerSize,
                                      decoration: BoxDecoration(
                                        color: _rowAxisCellColor(c),
                                        border: Border.all(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _buildAxisText(
                                        rowNumbers[c].displayText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Y軸（左側の縦並び数字）
              Positioned(
                left: 0,
                top: headerSize,
                width: headerSize,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _manualPanController,
                  builder: (context, _) {
                    final m = _manualPanController.value.storage;
                    final panY = showOverview ? 0.0 : m[13].clamp(minPanY, 0.0);
                    return ClipRect(
                      child: Transform.translate(
                        offset: Offset(0, panY),
                        // ★ 修正：OverflowBoxを追加し、親の高さ制約を無視して描画させる
                        child: OverflowBox(
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: Transform.scale(
                            alignment: Alignment.topCenter,
                            scale: showOverview ? overviewScale : 1.0,
                            child: SizedBox(
                              height: bodySize,
                              child: Column(
                                children: [
                                  for (int r = 0; r < 10; r++)
                                    Container(
                                      width: headerSize,
                                      height: cellSize,
                                      decoration: BoxDecoration(
                                        color: _colAxisCellColor(r),
                                        border: Border.all(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _buildAxisText(
                                        colNumbers[r].displayText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // メインの入力グリッド部分（変更なし）
              Positioned(
                left: headerSize,
                top: headerSize,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: InteractiveViewer(
                    transformationController: _manualPanController,
                    constrained: false,
                    minScale: 1.0,
                    maxScale: 1.0,
                    scaleEnabled: false,
                    panEnabled: !showOverview,
                    boundaryMargin: EdgeInsets.zero,
                    child: Transform.scale(
                      alignment: Alignment.topLeft,
                      scale: showOverview ? overviewScale : 1.0,
                      child: SizedBox(
                        width: bodySize,
                        height: bodySize,
                        child: Column(
                          children: [
                            for (int i = 0; i < 10; i++)
                              Row(
                                children: [
                                  for (int j = 0; j < 10; j++)
                                    Container(
                                      width: cellSize,
                                      height: cellSize,
                                      decoration: BoxDecoration(
                                        color: _cellColorFor(i, j),
                                        border: Border.all(
                                          color:
                                              (i == _selectedRow &&
                                                  j == _selectedCol &&
                                                  widget.manualInputMode &&
                                                  !_showAnswers)
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          width:
                                              (i == _selectedRow &&
                                                  j == _selectedCol &&
                                                  widget.manualInputMode &&
                                                  !_showAnswers)
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: _buildCellContent(i, j),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (height != null) {
      return SizedBox(height: height, child: content);
    }
    return content;
  }

  void _showAnswersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "正解",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF544275),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _buildAnswerOnlyGrid(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "閉じる",
                style: TextStyle(color: Color(0xFF544275)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnswerOnlyGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth / 11).clamp(24.0, 36.0);

        return SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: {
              for (int c = 0; c <= 10; c++) c: FixedColumnWidth(cellSize),
            },
            children: [
              TableRow(
                children: [
                  Container(height: cellSize, color: Colors.grey.shade200),
                  for (int c = 0; c < 10; c++)
                    Container(
                      height: cellSize,
                      color: Colors.blue.shade50,
                      alignment: Alignment.center,
                      child: _buildAxisText(
                        rowNumbers[c].displayText,
                        fontSize: cellSize * 0.4,
                      ),
                    ),
                ],
              ),
              for (int i = 0; i < 10; i++)
                TableRow(
                  children: [
                    Container(
                      height: cellSize,
                      color: Colors.orange.shade50,
                      alignment: Alignment.center,
                      child: _buildAxisText(
                        colNumbers[i].displayText,
                        fontSize: cellSize * 0.4,
                      ),
                    ),
                    for (int j = 0; j < 10; j++)
                      Container(
                        height: cellSize,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.calculateAnswer(
                              rowNumbers[j],
                              colNumbers[i],
                              widget.mode,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 164, 24, 24),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeAndCheckPanel() {
    final showPrintButton = !widget.manualInputMode && !_isStarted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth;
        final useCompactLayout = panelWidth < 560;
        final isTiny = panelWidth < 380;

        final horizontalPadding = isTiny ? 10.0 : 14.0;
        final verticalPadding = isTiny ? 8.0 : 10.0;
        final timerFontSize = isTiny ? 18.0 : (useCompactLayout ? 20.0 : 22.0);
        final buttonFontSize = isTiny ? 13.0 : 14.0;
        final buttonVerticalPadding = isTiny ? 8.0 : 10.0;
        final printButtonHorizontalPadding = isTiny
            ? 12.0
            : (useCompactLayout ? 14.0 : 12.0);
        final defaultButtonHorizontalPadding = isTiny
            ? 12.0
            : (useCompactLayout ? 16.0 : 25.0);
        final finishButtonHorizontalPadding = isTiny
            ? 10.0
            : (useCompactLayout ? 12.0 : 14.0);

        ButtonStyle buildOutlinedStyle(double horizontalPadding) {
          return OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: buttonVerticalPadding,
            ),
            side: const BorderSide(color: Color(0xFF544275)),
            foregroundColor: const Color(0xFF544275),
            textStyle: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          );
        }

        Widget actionButton;
        if (!_isStarted) {
          actionButton = OutlinedButton(
            key: const ValueKey('startButton'),
            onPressed: () {
              setState(() {
                _isStarted = true;
                _timer.start();
              });
            },
            style: buildOutlinedStyle(defaultButtonHorizontalPadding),
            child: Text("スタート", style: TextStyle(fontSize: buttonFontSize)),
          );
        } else if (!_isFinished) {
          actionButton = OutlinedButton(
            key: const ValueKey('finishButton'),
            onPressed: () {
              setState(() {
                _timer.stop();
                if (widget.manualInputMode) {
                  _score = _gradeManualAnswers();
                }
                _showAnswers = true;
                _isFinished = true;
              });
            },
            style: buildOutlinedStyle(finishButtonHorizontalPadding),
            child: Text(
              "フィニッシュ答え合わせ",
              style: TextStyle(fontSize: buttonFontSize),
            ),
          );
        } else {
          actionButton = OutlinedButton(
            key: const ValueKey('resultButton'),
            onPressed: _onResultPressed,
            style: buildOutlinedStyle(defaultButtonHorizontalPadding),
            child: Text("結果入力へ", style: TextStyle(fontSize: buttonFontSize)),
          );
        }

        final buttonGroup = Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: isTiny ? 6.0 : 8.0,
          runSpacing: 6,
          children: [
            if (showPrintButton)
              OutlinedButton.icon(
                key: const ValueKey('printButton'),
                onPressed: _onPrintPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: printButtonHorizontalPadding,
                    vertical: buttonVerticalPadding,
                  ),
                ),
                icon: const Icon(Icons.print),
                label: Text(
                  "印刷",
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (widget.manualInputMode && _isFinished)
              OutlinedButton.icon(
                key: const ValueKey('answersButton'),
                onPressed: _showAnswersDialog,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultButtonHorizontalPadding,
                    vertical: buttonVerticalPadding,
                  ),
                  side: const BorderSide(color: Color(0xFF544275)),
                  foregroundColor: const Color(0xFF544275),
                ),
                icon: const Icon(Icons.grid_on),
                label: Text(
                  "答えを見る",
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            actionButton,
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: useCompactLayout
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "タイム: $_timeDisplay",
                      style: TextStyle(
                        fontSize: timerFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: buttonGroup),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "タイム: $_timeDisplay",
                      style: TextStyle(
                        fontSize: timerFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    buttonGroup,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNormalModeGrid({Widget? bottomWidget}) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = (constraints.maxWidth / 11).clamp(28.0, 44.0);

          return SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    for (int c = 0; c <= 10; c++) c: FixedColumnWidth(cellSize),
                  },
                  children: [
                    TableRow(
                      children: [
                        Container(
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        for (int c = 0; c < 10; c++)
                          Container(
                            height: cellSize,
                            color: _rowAxisCellColor(c),
                            alignment: Alignment.center,
                            child: _buildAxisText(
                              rowNumbers[c].displayText,
                              fontSize: cellSize * 0.34,
                            ),
                          ),
                      ],
                    ),
                    for (int i = 0; i < 10; i++)
                      TableRow(
                        children: [
                          Container(
                            height: cellSize,
                            color: _colAxisCellColor(i),
                            alignment: Alignment.center,
                            child: _buildAxisText(
                              colNumbers[i].displayText,
                              fontSize: cellSize * 0.34,
                            ),
                          ),
                          for (int j = 0; j < 10; j++)
                            Container(
                              height: cellSize,
                              decoration: _cellDecorationFor(i, j),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              alignment: Alignment.center,
                              child: _buildCellContent(i, j),
                            ),
                        ],
                      ),
                  ],
                ),
                if (bottomWidget != null) ...[
                  const SizedBox(height: 12),
                  bottomWidget,
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculationUI() {
    if (!widget.manualInputMode) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildTimeAndCheckPanel(),
            const SizedBox(height: 8),
            _buildNormalModeGrid(),
          ],
        ),
      );
    }

    final showScore = _isFinished;
    final showKeypad = _isStarted && !_isFinished;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _updateTimePanelHeight();

          final availableHeight = constraints.maxHeight;
          final panelHeight = _timePanelHeight > 0 ? _timePanelHeight : 92.0;
          final keypadHeight = _estimateManualKeypadHeight(context);
          const double spacing = 14.0; // 8 + 6
          const double minGridHeight = 120.0;
          const double minKeypadHeight = 200.0;

          double gridHeight =
              availableHeight - panelHeight - spacing - keypadHeight;
          final maxGridHeightForKeypad =
              availableHeight - panelHeight - spacing - minKeypadHeight;
          gridHeight = min(gridHeight, maxGridHeightForKeypad);
          gridHeight = gridHeight.clamp(minGridHeight, availableHeight);

          final keypadAvailableHeight =
              (availableHeight - panelHeight - spacing - gridHeight).clamp(
                0.0,
                availableHeight,
              );
          final keypadNeedsScroll = keypadAvailableHeight < keypadHeight;

          return Column(
            children: [
              SizedBox(key: _timePanelKey, child: _buildTimeAndCheckPanel()),
              const SizedBox(height: 8),
              if (!_isStarted || _isFinished) ...[
                _buildNormalModeGrid(
                  bottomWidget: showScore
                      ? Text(
                          "正解数: $_score / 100",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        )
                      : null,
                ),
              ] else ...[
                SizedBox(
                  height: gridHeight,
                  child: _buildManualScrollableGrid(
                    height: gridHeight,
                    showOverview: false,
                  ),
                ),
                const SizedBox(height: 6),
                if (showKeypad)
                  SizedBox(
                    height: keypadAvailableHeight,
                    child: keypadNeedsScroll
                        ? SingleChildScrollView(child: _buildManualKeypad())
                        : _buildManualKeypad(),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isStarted,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('確認'),
              content: Text(
                _isFinished
                    ? '答え合わせ中です。\n本当に戻ってもよろしいですか？\n(戻ると記録は残りません)'
                    : 'タイム計測中です。\n本当に戻ってもよろしいですか？\n(戻ると記録は残りません)',
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(_isFinished ? 'ゲームを続ける' : 'ゲームを続ける'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('モード選択に戻る'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );

        if (shouldPop == true && mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            widget.mode,
            style: const TextStyle(
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
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildCalculationUI(),
            ),
          ),
        ),
      ),
    );
  }
}
