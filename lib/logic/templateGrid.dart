import 'package:flutter/material.dart';
import 'dart:math'; // ★ 追加：ランダム判定用
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(mode),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: TemplateMultiplicationBrain(
            rowMin: rowMin,
            rowMax: rowMax,
            colMin: colMin,
            colMax: colMax,
            mode: mode,
            manualInputMode: manualInputMode,
            calculateAnswer: calculateAnswer,
          ),
        ),
      ),
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

  late final List<List<String>> _manualInputs;
  late final List<List<bool?>> _cellCorrectness;

  final CalculationTimer _timer = CalculationTimer();

  @override
  void initState() {
    super.initState();
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
      _manualInputs[_selectedRow][_selectedCol] = '$current$value';
    });
  }

  void _deleteManualInput() {
    if (!widget.manualInputMode || _showAnswers) {
      return;
    }

    setState(() {
      final current = _manualInputs[_selectedRow][_selectedCol];
      if (current.isEmpty) {
        return;
      }
      _manualInputs[_selectedRow][_selectedCol] = current.substring(
        0,
        current.length - 1,
      );
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

  Widget _buildKeyButton({
    String? text,
    IconData? icon,
    double width = 80,
    double fontSize = 20,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: 60,
      child: FilledButton(
        onPressed: _showAnswers ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.indigo,
          disabledBackgroundColor: Colors.grey.shade400,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 20)
            : Text(
                text ?? '',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildManualKeypad() {
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
            children: [
              _buildKeyButton(text: '1', onTap: () => _appendManualInput('1')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '2', onTap: () => _appendManualInput('2')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '3', onTap: () => _appendManualInput('3')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '0', onTap: () => _appendManualInput('0')),
            ],
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
              _buildKeyButton(text: '/', onTap: () => _appendManualInput('/')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKeyButton(text: '7', onTap: () => _appendManualInput('7')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '8', onTap: () => _appendManualInput('8')),
              const SizedBox(width: 6),
              _buildKeyButton(text: '9', onTap: () => _appendManualInput('9')),
              const SizedBox(width: 6),
              _buildKeyButton(
                text: '削除',
                width: 80,
                fontSize: 14,
                onTap: _deleteManualInput,
              ),
            ],
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
        child: Center(
          child: Text(
            _manualInputs[row][col],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
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

  Widget _buildAxisText(String text, {double fontSize = 16}) {
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
    required double height,
    required bool showOverview,
  }) {
    const double cellSize = 56;
    const double headerSize = cellSize;
    final bodySize = cellSize * 10;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
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
                    color: Colors.grey.shade100,
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
                      final panX = showOverview
                          ? 0.0
                          : m[12].clamp(minPanX, 0.0);
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
                                          color: Colors.blue.shade50,
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
                      final panY = showOverview
                          ? 0.0
                          : m[13].clamp(minPanY, 0.0);
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
                                          color: Colors.orange.shade50,
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
      ),
    );
  }

  Widget _buildTimeAndCheckPanel() {
    final showPrintButton = !widget.manualInputMode && !_isStarted;

    Widget actionButton;
    if (!_isStarted) {
      actionButton = ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isStarted = true;
            _timer.start();
          });
        },
        label: const Text("スタート"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        ),
      );
    } else if (!_isFinished) {
      actionButton = ElevatedButton.icon(
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
        label: const Text("フィニッシュ答え合わせ"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      );
    } else {
      actionButton = ElevatedButton.icon(
        onPressed: _onResultPressed,
        label: const Text("結果入力へ"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "タイム: $_timeDisplay",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPrintButton)
                OutlinedButton.icon(
                  onPressed: _onPrintPressed,
                  icon: const Icon(Icons.print),
                  label: const Text("印刷"),
                ),
              if (showPrintButton) const SizedBox(width: 8),
              actionButton,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalModeGrid() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = (constraints.maxWidth / 11).clamp(28.0, 44.0);

          return SingleChildScrollView(
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                for (int c = 0; c <= 10; c++) c: FixedColumnWidth(cellSize),
              },
              children: [
                TableRow(
                  children: [
                    Container(height: cellSize, color: Colors.grey.shade100),
                    for (var rowItem in rowNumbers)
                      Container(
                        height: cellSize,
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: _buildAxisText(
                          rowItem.displayText,
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
                        color: Colors.orange.shade50,
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
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          alignment: Alignment.center,
                          child: _buildCellContent(i, j),
                        ),
                    ],
                  ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelAndGaps = 92.0;
        final scoreArea = showScore ? 44.0 : 0.0;
        final keypadArea = showKeypad ? 370.0 : 0.0;

        final manualGridHeight =
            (constraints.maxHeight - panelAndGaps - scoreArea - keypadArea)
                .clamp(170.0, 280.0);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildTimeAndCheckPanel(),
              const SizedBox(height: 8),
              if (!_isStarted || _isFinished)
                _buildNormalModeGrid()
              else
                _buildManualScrollableGrid(
                  height: manualGridHeight,
                  showOverview: false,
                ),
              const SizedBox(height: 6),
              if (showScore)
                Text(
                  "正解数: $_score / 100",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              if (showKeypad)
                SizedBox(height: 370, child: _buildManualKeypad()),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCalculationUI();
  }
}
