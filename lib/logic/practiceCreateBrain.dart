import 'package:flutter/material.dart';
import 'templateGrid.dart';
import '../screen/prepareTemplate.dart';

// 普通の掛け算
class OrdinaryMultiplicationPrepare extends StatelessWidget {
  const OrdinaryMultiplicationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "普通の掛け算",
      mode: "普通の掛け算",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "普通の掛け算",
      ),
    );
  }
}

// 上級の掛け算
class HighLevelMultiplicationPrepare extends StatelessWidget {
  const HighLevelMultiplicationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "上級の掛け算",
      defaultRowMax: "30",
      defaultRowMin: "11",
      mode : "上級の掛け算",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "上級の掛け算",
      ),
    );
  }
}

// 超上級の掛け算
class TopLevelMultiplicationPrepare extends StatelessWidget {
  const TopLevelMultiplicationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "超上級の掛け算",
      defaultRowMax: "999",
      defaultRowMin: "101",
      mode: "超上級の掛け算",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "超上級の掛け算",
      ),
    );
  }
}

// 割り算
class DivisionCalculationPrepare extends StatelessWidget {
  const DivisionCalculationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "割り算",
      defaultRowMax: "99",
      defaultRowMin: "11",
      mode: "割り算",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "割り算",
      ),
    );
  }
}

// ミックス計算
class MixCalculationPrepare extends StatelessWidget {
  const MixCalculationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "ミックス",
      defaultRowMax: "25",
      defaultRowMin: "11",
      mode: "ミックス",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "ミックス計算",
      ),
    );
  }
}

// 最大公約数
class MaxDivisorCalculationPrepare extends StatelessWidget {
  const MaxDivisorCalculationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "最大公約数",
      defaultRowMax: "99",
      defaultRowMin: "21",
      defaultColMax: "50",
      defaultColMin: "21",
      mode: "最大公約数",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "最大公約数",
      ),
    );
  }
}

// 循環する一の位
class CycleCalculationPrepare extends StatelessWidget {
  const CycleCalculationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "循環する一の位",
      defaultRowMax: "30",
      defaultRowMin: "5",
      defaultColMax: "50",
      defaultColMin: "1",
      mode: "循環",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "循環",
      ),
    );
  }
}