import 'package:flutter/material.dart';
import 'templateMultiplication.dart';
import 'DivisionCalculation.dart';
import 'MixCalculation.dart';
import 'ReverseCalculation.dart';
import 'HighLevelMultiplication.dart';
import 'prepareTemplate.dart';

// 普通の掛け算
class OrdinaryMultiplicationPrepare extends StatelessWidget {
  const OrdinaryMultiplicationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "普通の掛け算",
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
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "上級の掛け算",
      ),
    );
  }
}

//　超上級の掛け算
// 上級の掛け算
class TopLevelMultiplicationPrepare extends StatelessWidget {
  const TopLevelMultiplicationPrepare({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculationPrepareTemplate(
      title: "超上級の掛け算",
      defaultRowMax: "999",
      defaultRowMin: "101",
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => TemplateMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
        mode: "超上級の掛け算",
      ),
    );
  }
}