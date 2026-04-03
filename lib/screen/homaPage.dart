import 'package:flutter/material.dart';
import 'selectModeScreen.dart';
import 'recordScreen.dart';
import 'settingsScreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 共通のボタン作成メソッド
  Widget _buildCustomButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF544275).withOpacity(0.3),
            offset: const Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF67568C), // ボタンの紫
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // 枠線の内側に収まるようにする
          ),
          elevation: 0, // Container側で影をつけるため0にする
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // 背景のグラデーション
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCAB6F1), // 上部の薄紫
              Color(0xFFFBE0D1), // 下部のオレンジ/ピーチ
            ],
            stops: [0.2, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Color(0xFF544275),
                          size: 32,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 中央のイラスト（画像がないためアイコンで代用）
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.view_in_ar_rounded,
                                size: 150,
                                color: Color(0xFF544275),
                              ),
                              // 数字や記号の装飾イメージ
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Text(
                                  '1 2 3\n + x',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFDCA66A),
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // タイトルテキストとキラキラ
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '100マス計算練習',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF544275), // 濃い紫
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // 「100マス計算をする」ボタン
                          _buildCustomButton(
                            icon: const Icon(
                              Icons.grid_4x4,
                              size: 28,
                              color: Colors.white,
                            ),
                            text: '100マス計算をする',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectModeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 「記録を見る」ボタン
                          _buildCustomButton(
                            icon: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                Icon(
                                  Icons.emoji_events,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            text: '記録を見る',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecordScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 画面下部のステータス表示エリア
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFFCF5ED), // 少し黄味がかったオフホワイト
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '現在 3日連続！ 🏆',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A4A41), // 濃い茶色
                    ),
                  ),
                  const SizedBox(height: 16),

                  // プログレスインジケーター（ドット）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      final isActive = index < 2; // 最初の2つ（3日目進行中）をアクティブに
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFFFAAD74) // アクティブなオレンジ
                              : const Color(0xFFD9DAE0), // 非アクティブなグレー
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10), // 下部の余白
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
