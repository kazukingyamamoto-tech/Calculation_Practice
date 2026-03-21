import 'package:flutter/material.dart';

class CalculationPrepareTemplate extends StatefulWidget {
  final String title;
  final String defaultRowMin;
  final String defaultRowMax;
  final String defaultColMin;
  final String defaultColMax;
  final String mode;
  final Widget Function(BuildContext, int rMin, int rMax, int cMin, int cMax) destinationBuilder;

  const CalculationPrepareTemplate({
    super.key,
    required this.title,
    this.defaultRowMin = "1",
    this.defaultColMax = "10",
    this.defaultColMin = "1",
    this.defaultRowMax = "10",
    required this.destinationBuilder,
    required this.mode,
  });

  @override
  State<CalculationPrepareTemplate> createState() => _CalculationPrepareTemplateState();
}

class _CalculationPrepareTemplateState extends State<CalculationPrepareTemplate> {
  late final _rowMaxCtrl = TextEditingController(text: widget.defaultRowMax);
  late final _rowMinCtrl = TextEditingController(text: widget.defaultRowMin);
  late final _colMaxCtrl = TextEditingController(text: widget.defaultColMax);
  late final _colMinCtrl = TextEditingController(text: widget.defaultColMin);

  @override
  void dispose() {
    for (var c in [_rowMaxCtrl, _rowMinCtrl, _colMaxCtrl, _colMinCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onCalculatePressed() {
    int? rMax = int.tryParse(_rowMaxCtrl.text);
    int? rMin = int.tryParse(_rowMinCtrl.text);
    int? cMax = int.tryParse(_colMaxCtrl.text);
    int? cMin = int.tryParse(_colMinCtrl.text);
    String mode = widget.mode;



    if (rMax != null && rMin != null && cMax != null && cMin != null) {
      if (mode == "最大公約数") {
        if (rMin < 21 || cMin < 21) {
          _showSnackBar("横軸の最小値は21以上にしてください");
          return;
        }
      }
      if (mode == "上級の掛け算") {
        if (rMin < 10) {
          _showSnackBar("横軸の最小値は11以上にしてください");
          return;
        }
      }
      if (mode == "超上級の掛け算") {
        if (rMin < 100) {
          _showSnackBar("横軸の最小値は101以上にしてください");
          return;
        }
      }
      if (mode == "ミックス") {
        if (rMin < 10) {
          _showSnackBar("横軸の最小値は11以上にしてください");
          return;
        }
      }
      if (rMax - rMin >= 9 && cMax - cMin >= 9) {
        if (rMin < 1 || cMin < 1) {
          _showSnackBar("最小値は1以上にしてください");
          return;
        } else {
          // テンプレートなので、具体的な遷移先は widget.destinationBuilder に任せる
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.destinationBuilder(context, rMin, rMax, cMin, cMax),
            ),
          );
        }
      } else {
        _showSnackBar("最大値は最小値より9以上大きくしてください");
      }
    } else {
      _showSnackBar("正しい数値を入力してください");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40),
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => showTutorialDialog(context), // 共通関数を呼ぶ
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildField('横軸最小', _rowMinCtrl),
            _buildField('横軸最大', _rowMaxCtrl),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildField('縦軸最小', _colMinCtrl),
            _buildField('縦軸最大', _colMaxCtrl),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _onCalculatePressed,
          child: const Text("100マス計算生成"),
        ),
      ],
    );
  }

  Widget _buildField(String title, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Container(
          width: 150,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700, width: 2),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

void showTutorialDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("入力方法"),
      content: const Text("最大値と最小値を入力してください。差が9以上必要です。"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("閉じる")),
      ],
    ),
  );
}