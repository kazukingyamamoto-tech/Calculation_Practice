import 'package:flutter/material.dart';
import 'dart:math' as math;

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final int row_upper = 10;
    final int row_lower = 1;
    final int column_upper = 10;
    final int column_lower = 1;
    List row_numbers = List.generate(
      10,
      (index) => math.Random().nextInt(row_upper - row_lower + 1) + row_lower,
    );
    List column_numbers = List.generate(
      10,
      (index) =>
          math.Random().nextInt(column_upper - column_lower + 1) + column_lower,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Practice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 40,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2.0,
                      ),
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: TextEditingController(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '横列の最大値を入力',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 99, 95, 95),
                          fontSize: 12,
                        ),
                        contentPadding: EdgeInsets.only(left: 8.0, bottom: 0.0),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 40,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2.0,
                      ),
                    ),

                    margin: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: TextEditingController(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '横列の最小値を入力',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 99, 95, 95),
                          fontSize: 12,
                        ),
                        contentPadding: EdgeInsets.only(left: 8.0, bottom: 0.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 40,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2.0,
                      ),
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: TextEditingController(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '縦列の最大値を入力',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 99, 95, 95),
                          fontSize: 12,
                        ),
                        contentPadding: EdgeInsets.only(left: 8.0, bottom: 0.0),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 40,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2.0,
                      ),
                    ),

                    margin: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: TextEditingController(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '縦列の最小値を入力',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 99, 95, 95),
                          fontSize: 12,
                        ),
                        contentPadding: EdgeInsets.only(left: 8.0, bottom: 0.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
