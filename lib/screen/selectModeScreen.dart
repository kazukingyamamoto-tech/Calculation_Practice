import 'package:flutter/material.dart';
import '../logic/practiceCreateBrain.dart';

class SelectModeScreen extends StatefulWidget {
  const SelectModeScreen({super.key});

  @override
  State<SelectModeScreen> createState() => _SelectModeScreenState();
}

class _SelectModeScreenState extends State<SelectModeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('計算の種類を選ぶ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdinaryMultiplication(),
                  ),
                );
              },
              child: const Text('普通の掛け算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HighLevelMultiplication(),
                  ),
                );
              },
              child: const Text('上級の掛け算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TopLevelMultiplication(),
                  ),
                );
              },
              child: const Text('超上級の掛け算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DivisionCalculation(),
                  ),
                );
              },
              child: const Text('割り算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MixCalculation(),
                  ),
                );
              },
              child: const Text('ミックス計算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaxDivisorCalculation(),
                  ),
                );
              },
              child: const Text('最大公約数の計算'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CycleCalculation(),
                  ),
                );
              },
              child: const Text('循環する一の位の計算'),
            ),
          ],
        ),
      ),
    );
  }
}

//OrdinaryMultiplication.dart
class OrdinaryMultiplication extends StatefulWidget {
  const OrdinaryMultiplication({super.key});

  @override
  State<OrdinaryMultiplication> createState() => _OrdinaryMultiplicationState();
}

class _OrdinaryMultiplicationState extends State<OrdinaryMultiplication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('普通の掛け算'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [OrdinaryMultiplicationPrepare()],
        ),
      ),
    );
  }
}

// // HighLevelMultiplication.dart
class HighLevelMultiplication extends StatefulWidget {
  const HighLevelMultiplication({super.key});

  @override
  State<HighLevelMultiplication> createState() =>
      _HighLevelMultiplicationState();
}

class _HighLevelMultiplicationState extends State<HighLevelMultiplication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('上級の掛け算'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [HighLevelMultiplicationPrepare()],
        ),
      ),
    );
  }
}

// // TopLevelMultiplication.dart
class TopLevelMultiplication extends StatefulWidget {
  const TopLevelMultiplication({super.key});

  @override
  State<TopLevelMultiplication> createState() =>
      _TopLevelMultiplicationState();
}

class _TopLevelMultiplicationState extends State<TopLevelMultiplication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('超上級の掛け算'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [TopLevelMultiplicationPrepare()],
        ),
      ),
    );
  }
}

// 最大公約数
class MaxDivisorCalculation extends StatefulWidget {
  const MaxDivisorCalculation({super.key});

  @override
  State<MaxDivisorCalculation> createState() =>
      _MaxDivisorCalculationState();
}

class _MaxDivisorCalculationState extends State<MaxDivisorCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('最大公約数の計算'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [MaxDivisorCalculationPrepare()],)),
    );
  }
}

// DivisionCalculation.dart
class DivisionCalculation extends StatefulWidget {
  const DivisionCalculation({super.key});

  @override
  State<DivisionCalculation> createState() =>
      _DivisionCalculationState();
}

class _DivisionCalculationState extends State<DivisionCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('割り算'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [DivisionCalculationPrepare()],)),
    );
  }
}

// MixCalculation.dart
class MixCalculation extends StatefulWidget {
  const MixCalculation({super.key});

  @override
  State<MixCalculation> createState() =>
      _MixCalculationState();
}

class _MixCalculationState extends State<MixCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ミックス'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [MixCalculationPrepare()],)),
    );
  }
}

// 最大公約数
class CycleCalculation extends StatefulWidget {
  const CycleCalculation({super.key});

  @override
  State<CycleCalculation> createState() =>
      _CycleCalculationState();
}

class _CycleCalculationState extends State<CycleCalculation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('循環する一の位の計算'),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [CycleCalculationPrepare()],)),
    );
  }
}