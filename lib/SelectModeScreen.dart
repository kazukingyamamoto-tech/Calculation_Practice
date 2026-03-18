import 'package:flutter/material.dart';
import 'PracticePrepareScreen.dart';

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
        title: const Text('Select Mode'),
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
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const DivisionCalculation(),
            //       ),
            //     );
            //   },
            //   child: const Text('割り算'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const ReverseCalculation(),
            //       ),
            //     );
            //   },
            //   child: const Text('逆算'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const MixCalculation(),
            //       ),
            //     );
            //   },
            //   child: const Text('混合計算'),
            // ),
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
        title: const Text('Ordinary Multiplication'),
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
        title: const Text('High Level Multiplication'),
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

// // DivisionCalculation.dart
// class DivisionCalculation extends StatefulWidget {
//   const DivisionCalculation({super.key});

//   @override
//   State<DivisionCalculation> createState() =>
//       _DivisionCalculationState();
// }

// class _DivisionCalculationState extends State<DivisionCalculation> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Division Calculation'),
//       ),
//       body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [DivisionCalculationBrain()],)),
//     );
//   }
// }

// // ReverseCalculation.dart
// class ReverseCalculation extends StatefulWidget {
//   const ReverseCalculation({super.key});

//   @override
//   State<ReverseCalculation> createState() =>
//       _ReverseCalculationState();
// }

// class _ReverseCalculationState extends State<ReverseCalculation> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Reverse Calculation'),
//       ),
//       body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [ReverseCalculationBrain()],)),
//     );
//   }
// }

// // MixCalculation.dart
// class MixCalculation extends StatefulWidget {
//   const MixCalculation({super.key});

//   @override
//   State<MixCalculation> createState() =>
//       _MixCalculationState();
// }

// class _MixCalculationState extends State<MixCalculation> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Mix Calculation'),
//       ),
//       body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [MixCalculationBrain()],)),
//     );
//   }
// }
