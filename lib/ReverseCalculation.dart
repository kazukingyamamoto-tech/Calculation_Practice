import 'package:flutter/material.dart';

class ReverseCalculation extends StatefulWidget {
  const ReverseCalculation({super.key});

  @override
  State<ReverseCalculation> createState() => _ReverseCalculationState();
}

class _ReverseCalculationState extends State<ReverseCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Reverse Calculation'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center)),
    );
  }
}
