import 'package:flutter/material.dart';

class MixCalculation extends StatefulWidget {
  const MixCalculation({super.key});

  @override
  State<MixCalculation> createState() => _MixCalculationState();
}

class _MixCalculationState extends State<MixCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Mix Calculation'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center)),
    );
  }
}
