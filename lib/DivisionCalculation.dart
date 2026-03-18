import 'package:flutter/material.dart';

class DivisionCalculation extends StatefulWidget {
  const DivisionCalculation({super.key});

  @override
  State<DivisionCalculation> createState() => _DivisionCalculationState();
}

class _DivisionCalculationState extends State<DivisionCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Division Calculation'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center)),
    );
  }
}
