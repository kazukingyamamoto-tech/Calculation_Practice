import 'package:flutter/material.dart';
import 'OrdinaryMultiplication.dart';
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
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => OrdinaryMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
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
      destinationBuilder: (context, rMin, rMax, cMin, cMax) => HighLevelMultiplication(
        rowMin: rMin, rowMax: rMax, colMin: cMin, colMax: cMax,
      ),
    );
  }
}