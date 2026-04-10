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
  final List<String> _tutorialNormalImages = [
    'assets/usual_1.png',
    'assets/usual_2.png',
    'assets/usual_3.png',
    'assets/usual_4.png',
  ];

  final List<String> _tutorialNormalCaptions = [
    'プレイする100マスを選択したら、\n通常モードを選んでスタートしよう！',
    '印刷ボタンから100マスを印刷したら、\nスタートを押して答えを書き込もう！',
    'すべてのマスに答えを書き込んだら、\n答え合わせをしよう！',
    '名前と正解できた数を入力して、\n記録を保存しよう！',
  ];

  final List<String> _tutorialManualImages = [
    'assets/manual_1.png',
    'assets/manual_2.png',
    'assets/manual_3.png',
    'assets/manual_4.png',
  ];

  final List<String> _tutorialManualCaptions = [
    'プレイする100マスを選択したら、\n手入力モードを選んでスタートしよう！',
    '青い枠線で囲まれているマスに、\n下のキーパッドを使って答えを入力！',
    '答え合わせを押すと自動で採点！\n（答えを見るボタンから正解が見よう！）',
    '正解できた数を確認したら、\n名前を入力して、記録を保存しよう！',
  ];

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

  void _showTutorialDialog() {
    final pageController = PageController();
    showDialog(
      context: context,
      builder: (context) {
        String selectedMode = 'normal';
        int currentPage = 0;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final images = selectedMode == 'normal'
                ? _tutorialNormalImages
                : _tutorialManualImages;
            final captions = selectedMode == 'normal'
                ? _tutorialNormalCaptions
                : _tutorialManualCaptions;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'チュートリアル',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF544275),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setLocalState(() {
                                selectedMode = 'normal';
                                currentPage = 0;
                              });
                              pageController.jumpToPage(0);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF544275)),
                              foregroundColor: const Color(0xFF544275),
                              backgroundColor: selectedMode == 'normal'
                                  ? const Color(0xFFEFE6FF)
                                  : Colors.transparent,
                            ),
                            child: const Text('通常モード'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setLocalState(() {
                                selectedMode = 'manual';
                                currentPage = 0;
                              });
                              pageController.jumpToPage(0);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF544275)),
                              foregroundColor: const Color(0xFF544275),
                              backgroundColor: selectedMode == 'manual'
                                  ? const Color(0xFFEFE6FF)
                                  : Colors.transparent,
                            ),
                            child: const Text('手入力モード'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 360,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setLocalState(() {
                            currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: const Color(0xFFF2F2F2),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                '画像が見つかりません',
                                                style: TextStyle(
                                                  color: Color(0xFF544275),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  captions[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF544275),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: currentPage == index ? 10 : 8,
                          height: currentPage == index ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? const Color(0xFF67568C)
                                : const Color(0xFFD9DAE0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('閉じる'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => pageController.dispose());
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
                      left: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Color(0xFF544275),
                          size: 32,
                        ),
                        onPressed: _showTutorialDialog,
                      ),
                    ),
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
                                '100Math基礎練習',
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
                          Container(
                            child: _buildCustomButton(
                              icon: const Icon(
                                Icons.grid_4x4,
                                size: 28,
                                color: Colors.white,
                              ),
                              text: '100マス練習をする',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SelectModeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 「記録を見る」ボタン
                          Container(
                            child: _buildCustomButton(
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
