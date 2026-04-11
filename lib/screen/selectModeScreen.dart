import 'package:flutter/material.dart';
import '../logic/templateGrid.dart';

class GameMode {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCustom;
  final String? imagePath;
  final Widget Function(BuildContext, bool)? onStart;

  GameMode({
    required this.title,
    this.description = "",
    required this.icon,
    required this.color,
    this.isCustom = false,
    this.imagePath,
    this.onStart,
  });
}

class SelectModeScreen extends StatefulWidget {
  const SelectModeScreen({super.key});

  @override
  State<SelectModeScreen> createState() => _SelectModeScreenState();
}

class _SelectModeScreenState extends State<SelectModeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  static const double _minLandscapeSafeHeight = 550;
  int _currentIndex = 0;
  bool _isManualInputMode = false;

  // --- 絞り込み用の状態管理 ---
  String _selectedCategory = 'すべて';
  final List<String> _categories = ['すべて', 'かけ算', 'わり算', 'その他'];

  // --- カスタムモード用の状態管理 ---
  String _selectedCustomLogic = "普通のかけ算";
  final _rowMinCtrl = TextEditingController(text: "1");
  final _rowMaxCtrl = TextEditingController(text: "10");
  final _colMinCtrl = TextEditingController(text: "1");
  final _colMaxCtrl = TextEditingController(text: "10");

  @override // ★ disposeには @override が必要です
  void dispose() {
    _colMaxCtrl.dispose();
    _colMinCtrl.dispose();
    _rowMaxCtrl.dispose();
    _rowMinCtrl.dispose();
    _pageController.dispose(); // これも忘れずに破棄
    super.dispose();
  }

  // --- ★追加：選んだモードに合わせてデフォルト値を入力欄にセットする関数 ---
  void _updateCustomDefaults(String modeName) {
    switch (modeName) {
      case '普通のかけ算':
        _rowMinCtrl.text = "1";
        _rowMaxCtrl.text = "10";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10";
        break;
      case 'わり算（分数）':
        _rowMinCtrl.text = "15";
        _rowMaxCtrl.text = "24";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10"; // 1の段は簡単すぎるので2〜9など
        break;
      case '上級のわり算（分数）':
        _rowMinCtrl.text = "34";
        _rowMaxCtrl.text = "50";
        _colMinCtrl.text = "24";
        _colMaxCtrl.text = "40"; // 1の段は簡単すぎるので2〜9など
        break;
      case '分数の足し算':
        _rowMinCtrl.text = "2";
        _rowMaxCtrl.text = "9";
        _colMinCtrl.text = "2";
        _colMaxCtrl.text = "9";
        break;
      case 'かけ算（小数）':
        _rowMinCtrl.text = "11";
        _rowMaxCtrl.text = "99";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10";
        break;
      case 'わり算（小数）':
        _rowMinCtrl.text = "15";
        _rowMaxCtrl.text = "45";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10";
        break;
      case '上級のわり算（小数）':
        _rowMinCtrl.text = "30";
        _rowMaxCtrl.text = "95";
        _colMinCtrl.text = "11";
        _colMaxCtrl.text = "25";
        break;
      case 'ミックス計算':
        _rowMinCtrl.text = "11";
        _rowMaxCtrl.text = "25";
        _colMinCtrl.text = "2";
        _colMaxCtrl.text = "11";
        break;
      case '最大公約数':
        _rowMinCtrl.text = "20";
        _rowMaxCtrl.text = "40";
        _colMinCtrl.text = "20";
        _colMaxCtrl.text = "40";
        break;
      case '最小公倍数':
        _rowMinCtrl.text = "4";
        _rowMaxCtrl.text = "30";
        _colMinCtrl.text = "4";
        _colMaxCtrl.text = "30";
        break;
      case '循環する一の位':
        _rowMinCtrl.text = "5";
        _rowMaxCtrl.text = "30";
        _colMinCtrl.text = "11";
        _colMaxCtrl.text = "50";
        break;
      default:
        _rowMinCtrl.text = "1";
        _rowMaxCtrl.text = "10";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10";
        break;
    }
  }

  // モードのリスト定義
  late final List<GameMode> _modes = [
    GameMode(
      title: "普通のかけ算",
      description: "一桁×一桁の100マス計算。\nまずは九九を正確に極めよう！",
      icon: Icons.grid_on,
      color: Colors.redAccent,
      imagePath: "assets/mode_1.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 1,
        rowMax: 10,
        colMin: 1,
        colMax: 10,
        mode: "普通のかけ算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "上級のかけ算",
      description: "一桁×二桁の100マス計算。\n素早く正確に計算しよう！",
      icon: Icons.calculate,
      color: Colors.orangeAccent,
      imagePath: "assets/mode_2.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 11,
        rowMax: 25,
        colMin: 1,
        colMax: 10,
        mode: "上級のかけ算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "超上級のかけ算",
      description: "二桁×三桁の100マス計算。\n限界に挑戦しよう！",
      icon: Icons.bolt,
      color: Colors.deepOrange,
      imagePath: "assets/mode_3.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 101,
        rowMax: 500,
        colMin: 1,
        colMax: 10,
        mode: "超上級のかけ算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "かけ算（小数）",
      description: "小数第一位までの数と\n一桁の数のかけ算を練習しよう。\n小数点の位置に注意して答えよう！",
      icon: Icons.functions,
      color: Colors.lightBlue,
      imagePath: "assets/mode_4.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 11,
        rowMax: 99,
        colMin: 1,
        colMax: 10,
        mode: "かけ算（小数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "わり算（分数）",
      description:
          "二桁÷一桁の計算。\n割り切れない時は分数にして、\n約分にも注意して答えよう！\n（手入力モードでは、\n分子/分母の順で答えよう）",
      icon: Icons.horizontal_split,
      color: Colors.blueAccent,
      imagePath: "assets/mode_5.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 15,
        rowMax: 24,
        colMin: 2,
        colMax: 10,
        mode: "わり算（分数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "上級のわり算（分数）",
      description:
          "二桁÷二桁の計算。\nわり切れない時は分数にして、\n約分にも注意して答えよう！\n（手入力モードの場合は、\n分子/分母の順で答えよう）",
      icon: Icons.horizontal_rule,
      color: Colors.blueGrey,
      imagePath: "assets/mode_6.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 34,
        rowMax: 50,
        colMin: 24,
        colMax: 40,
        mode: "上級のわり算（分数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "わり算（小数）",
      description: "二桁÷一桁の計算。\nわり切れない場合は四捨五入して、\n小数点第1位までで答えよう！",
      icon: Icons.looks_one,
      color: Colors.blue,
      imagePath: "assets/mode_7.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 15,
        rowMax: 45,
        colMin: 1,
        colMax: 10,
        mode: "わり算（小数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "上級のわり算（小数）",
      description: "二桁÷二桁に挑戦！\nわり切れない場合は四捨五入して、\n小数点第1位までで答えよう！",
      icon: Icons.looks_two,
      color: Colors.blueGrey,
      imagePath: "assets/mode_8.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 30,
        rowMax: 95,
        colMin: 11,
        colMax: 25,
        mode: "上級のわり算（小数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "ミックス計算",
      description: "かけ算とわり算がランダムに出現！\n瞬時の判断力を鍛えよう。\n割り切れないときは分数で答えよう。",
      icon: Icons.casino,
      color: Colors.purpleAccent,
      imagePath: "assets/mode_9.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 11,
        rowMax: 25,
        colMin: 2,
        colMax: 11,
        mode: "ミックス計算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "分数の足し算",
      description:
          "分数 + 分数 の計算に挑戦！\n通分して足し算し、\n約分にも注意して答えよう！\n（手入力では 分子/分母 で入力）",
      icon: Icons.exposure_plus_1,
      color: Colors.teal,
      imagePath: "assets/mode_13.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 2,
        rowMax: 9,
        colMin: 2,
        colMax: 9,
        mode: "分数の足し算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "最大公約数",
      description: "2つの数字の最大公約数を求めよう。\n素早く正確に答えて感覚を鍛えよう！",
      icon: Icons.hub,
      color: Colors.indigo,
      imagePath: "assets/mode_10.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 20,
        rowMax: 40,
        colMin: 20,
        colMax: 40,
        mode: "最大公約数",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "最小公倍数",
      description: "2つの数字の最小公倍数を求めよう。\n約数と倍数の感覚を鍛えよう！",
      icon: Icons.all_inclusive,
      color: Colors.cyan,
      imagePath: "assets/mode_11.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 4,
        rowMax: 30,
        colMin: 4,
        colMax: 30,
        mode: "最小公倍数",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "循環する一の位",
      description: "横の数字を縦の数字の数分\nかけ合わせた数の一の位を答えよう！\n累乗の法則からパターンを見抜こう！",
      icon: Icons.sync,
      color: Colors.green,
      imagePath: "assets/mode_12.png",
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 5,
        rowMax: 30,
        colMin: 11,
        colMax: 50,
        mode: "循環する一の位",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "カスタムモード",
      icon: Icons.tune,
      color: Colors.teal,
      isCustom: true, // カスタムフラグをON！
    ),
  ];

  // 絞り込み用の計算プロパティ
  List<GameMode> get _filteredModes {
    if (_selectedCategory == 'すべて') return _modes;

    return _modes.where((mode) {
      if (mode.isCustom) return true; // カスタムは常に最後に追加
      if (_selectedCategory == 'かけ算' && mode.title.contains('かけ算')) return true;
      if (_selectedCategory == 'わり算' && mode.title.contains('わり算')) return true;
      if (_selectedCategory == 'その他' &&
          !mode.title.contains('かけ算') &&
          !mode.title.contains('わり算'))
        return true;
      return false;
    }).toList();
  }

  // カスタムモードのスタートボタン処理
  void _startCustomMode() {
    int? rMin = int.tryParse(_rowMinCtrl.text);
    int? rMax = int.tryParse(_rowMaxCtrl.text);
    int? cMin = int.tryParse(_colMinCtrl.text);
    int? cMax = int.tryParse(_colMaxCtrl.text);

    if (rMax != null && rMin != null && cMax != null && cMin != null) {
      if (rMax >= rMin && cMax >= cMin) {
        final rowCount = (rMax - rMin + 1).abs();
        final colCount = (cMax - cMin + 1).abs();
        if (rowCount < 10 || colCount < 10) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("行・列ともに10以上の範囲が必要です")));
          return;
        }
        // カスタムモードは Prepare を飛ばして直接スタート！
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemplateMultiplication(
              rowMin: rMin,
              rowMax: rMax,
              colMin: cMin,
              colMax: cMax,
              mode: _selectedCustomLogic,
              recordMode: 'カスタム',
              manualInputMode: _isManualInputMode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("最大値は最小値より大きくしてください")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("正しい数値を入力してください")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          '100マスの種類を選ぶ',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF544275),
          ),
        ),
        elevation: 0,
        foregroundColor: const Color(0xFF544275),
        iconTheme: const IconThemeData(color: Color(0xFF544275)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCAB6F1), Color(0xFFFBE0D1)],
            stops: [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shouldShowPortraitGuide =
                  isLandscape &&
                  constraints.maxHeight < _minLandscapeSafeHeight;

              if (shouldShowPortraitGuide) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '表示が崩れるため、縦向きにしてください',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 10),
                  // --- カテゴリ絞り込みドロップダウン ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        const Text(
                          '絞り込み: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF544275),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: false,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF544275),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF544275),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          items: _categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                                _currentIndex = 0;
                              });
                              if (_pageController.hasClients) {
                                _pageController.jumpToPage(0);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // --- 上半分：スワイプできるカード部分 ---
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: _filteredModes.length,
                      itemBuilder: (context, index) {
                        final mode = _filteredModes[index];
                        final isSelected = _currentIndex == index;
                        final scale = isSelected ? 1.0 : 0.9;

                        return TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: scale, end: scale),
                          curve: Curves.easeOut,
                          builder: (context, double value, child) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Transform.scale(
                                scale: value,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  elevation: isSelected ? 8 : 2,
                                  color: mode.color,
                                  child: mode.isCustom
                                      ? _buildCustomCard()
                                      : _buildNormalCard(mode),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- 下半分：スタートボタン ---
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _filteredModes[_currentIndex].isCustom
                          ? _buildCustomBottomArea()
                          : _buildNormalBottomArea(
                              _filteredModes[_currentIndex],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _descriptionFontSize(String description) {
    final compact = description.replaceAll('\n', '').replaceAll(' ', '');
    final length = compact.length;

    if (length <= 26) {
      return 19;
    }
    if (length <= 40) {
      return 18;
    }
    if (length <= 58) {
      return 17;
    }
    return 16;
  }

  // --- カード中身（通常） ---
  Widget _buildNormalCard(GameMode mode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        children: [
          Icon(mode.icon, size: 54, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            mode.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // 1. 上のテキスト部分: Flexible を Expanded に変更！
          Expanded(
            child: Container(
              width: double.infinity, // 横幅いっぱいまで広げたい場合に追加
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Text(
                    mode.description,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _descriptionFontSize(mode.description),
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. 下の画像スペース: Expanded と Align を外す！
          Container(
            width: double.infinity,
            // 💡 もし画像の高さが大きすぎてはみ出る場合は、ここに height: 200 などを指定するか、
            // Container の代わりに AspectRatio(aspectRatio: 1.0, ...) で囲むと綺麗な形を保てます。
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white70, width: 1.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                mode.imagePath ?? "",
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      "画像が見つかりません",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- カード中身（カスタム：ドロップダウン付き） ---
  Widget _buildCustomCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        children: [
          const Icon(Icons.settings_suggest, size: 54, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            "自分だけのルールを作る",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCustomLogic,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              items:
                  [
                        '普通のかけ算',
                        'わり算（分数）',
                        '分数の足し算',
                        'わり算（小数）',
                        '上級のわり算（小数）',
                        'ミックス計算',
                        '最大公約数',
                        '最小公倍数',
                        '循環する一の位',
                      ]
                      .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCustomLogic = val!;
                  _updateCustomDefaults(val);
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white70, width: 1.2),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "数字の範囲を設定",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField("横軸 最小", _rowMinCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildNumberField("横軸 最大", _rowMaxCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField("縦軸 最小", _colMinCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildNumberField("縦軸 最大", _colMaxCtrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 下部エリア（通常） ---
  Widget _buildNormalBottomArea(GameMode mode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _filteredModes.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? _filteredModes[_currentIndex].color
                    : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 27),
        _buildInputModeSwitch(),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      mode.onStart!(context, _isManualInputMode),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 2.0),
              backgroundColor: mode.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'このモードでスタート！',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
            height: (MediaQuery.of(context).size.height * 0.04)
              .clamp(20.0, 48.0)
              .toDouble(),
        ),
      ],
    );
  }

  // --- 下部エリア（カスタム用入力フォーム） ---
  Widget _buildCustomBottomArea() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _filteredModes.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? _filteredModes[_currentIndex].color
                    : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildInputModeSwitch(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _startCustomMode,
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 2.0),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'カスタムでスタート！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInputModeSwitch() {
    return Center(
      child: Container(
        width: 260, // ここで全体の幅を制限
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          children: [
            // 通常モードボタン
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isManualInputMode = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isManualInputMode
                        ? const Color(0xFF67568C)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "通常モード",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: !_isManualInputMode
                          ? Colors.white
                          : const Color(0xFF67568C),
                    ),
                  ),
                ),
              ),
            ),
            // 手入力モードボタン
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isManualInputMode = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isManualInputMode
                        ? const Color(0xFF67568C)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "手入力モード",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isManualInputMode
                          ? Colors.white
                          : const Color(0xFF67568C),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 入力フィールドの共通パーツ ---
  Widget _buildNumberField(String label, TextEditingController ctrl) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 42,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
