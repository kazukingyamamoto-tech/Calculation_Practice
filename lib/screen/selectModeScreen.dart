import 'package:flutter/material.dart';
import '../logic/templateGrid.dart';

class GameMode {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCustom;
  final Widget Function(BuildContext, bool)? onStart;

  GameMode({
    required this.title,
    this.description = "",
    required this.icon,
    required this.color,
    this.isCustom = false,
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
  final List<String> _categories = ['すべて', '掛け算', '割り算', 'その他'];

  // --- カスタムモード用の状態管理 ---
  String _selectedCustomLogic = "普通の掛け算";
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
      case '普通の掛け算':
        _rowMinCtrl.text = "1";
        _rowMaxCtrl.text = "10";
        _colMinCtrl.text = "1";
        _colMaxCtrl.text = "10";
        break;
      case '割り算':
        _rowMinCtrl.text = "15";
        _rowMaxCtrl.text = "24";
        _colMinCtrl.text = "2";
        _colMaxCtrl.text = "11"; // 1の段は簡単すぎるので2〜9など
        break;
      case '少数の掛け算':
        _rowMinCtrl.text = "11";
        _rowMaxCtrl.text = "99";
        _colMinCtrl.text = "2";
        _colMaxCtrl.text = "9";
        break;
      case '割り算の少数でこたえを出す':
        _rowMinCtrl.text = "15";
        _rowMaxCtrl.text = "45";
        _colMinCtrl.text = "2";
        _colMaxCtrl.text = "9";
        break;
      case '割り算の少数でこたえを出すレベル２':
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
      case '循環':
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
      title: "普通の掛け算",
      description: "一桁×一桁の基本的な100マス計算！\nまずはスピードと正確さを極めよう。",
      icon: Icons.grid_on,
      color: Colors.redAccent,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 1,
        rowMax: 10,
        colMin: 1,
        colMax: 10,
        mode: "普通の掛け算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "上級の掛け算",
      description: "一桁×二桁の100マス計算！\n素早く正確に計算しよう。",
      icon: Icons.calculate,
      color: Colors.orangeAccent,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 11,
        rowMax: 25,
        colMin: 1,
        colMax: 10,
        mode: "上級の掛け算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "超上級の掛け算",
      description: "二桁×三桁の100マス計算！\n限界に挑戦しよう。",
      icon: Icons.bolt,
      color: Colors.deepOrange,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 101,
        rowMax: 500,
        colMin: 10,
        colMax: 1,
        mode: "超上級の掛け算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "少数の掛け算",
      description: "1.8×4 や 2.3×7 など\n少数第一位までの掛け算を練習！",
      icon: Icons.functions,
      color: Colors.lightBlue,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 11,
        rowMax: 99,
        colMin: 2,
        colMax: 9,
        mode: "少数の掛け算",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "割り算（分数）",
      description: "二桁÷一桁の計算！\n割り切れない時は分数にしよう。",
      icon: Icons.horizontal_split,
      color: Colors.blueAccent,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 15,
        rowMax: 24,
        colMin: 2,
        colMax: 11,
        mode: "割り算（分数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "割り算（少数）",
      description: "二桁÷一桁。割り切れない場合は\n四捨五入して小数第1位まで！",
      icon: Icons.looks_one,
      color: Colors.blue,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 15,
        rowMax: 45,
        colMin: 2,
        colMax: 9,
        mode: "割り算（少数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "上級の割り算（少数）",
      description: "二桁÷二桁に挑戦！\n割り切れない場合は小数第1位まで！",
      icon: Icons.looks_two,
      color: Colors.blueGrey,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 30,
        rowMax: 95,
        colMin: 11,
        colMax: 25,
        mode: "上級の割り算（少数）",
        manualInputMode: isManualInputMode,
      ),
    ),
    GameMode(
      title: "ミックス計算",
      description: "掛け算と割り算がランダムに出現！\n瞬時の判断力を鍛えよう。",
      icon: Icons.casino,
      color: Colors.purpleAccent,
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
      title: "最大公約数の計算",
      description: "2つの数字の最大公約数を求めよう！\nパズルのように解き明かせ。",
      icon: Icons.hub,
      color: Colors.indigo,
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
      title: "最小公倍数の計算",
      description: "2つの数字の最小公倍数を求めよう！\n約数と倍数の感覚を鍛えよう。",
      icon: Icons.all_inclusive,
      color: Colors.cyan,
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
      description: "累乗の法則を見抜いて、\n一の位の数を素早く導き出そう！",
      icon: Icons.sync,
      color: Colors.green,
      onStart: (context, isManualInputMode) => TemplateMultiplication(
        rowMin: 5,
        rowMax: 30,
        colMin: 11,
        colMax: 50,
        mode: "循環",
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
      if (_selectedCategory == '掛け算' && mode.title.contains('掛け算')) return true;
      if (_selectedCategory == '割り算' && mode.title.contains('割り算')) return true;
      if (_selectedCategory == 'その他' &&
          !mode.title.contains('掛け算') &&
          !mode.title.contains('割り算'))
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
          '計算の種類を選ぶ',
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
                            return Transform.scale(
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
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

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
          const SizedBox(height: 10),
          Text(
            mode.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white70, width: 1.2),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, color: Colors.white, size: 28),
                    SizedBox(height: 6),
                    Text(
                      "写真スペース",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "ここに説明画像を配置できます",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
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
                        '普通の掛け算',
                        '割り算（分数）',
                        '割り算（少数）',
                        '上級の割り算（少数）',
                        'ミックス計算',
                        '最大公約数',
                        '最小公倍数',
                        '循環',
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
        const SizedBox(height: 22),
        _buildInputModeSwitch(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
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
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _buildInputModeSwitch(),
        const SizedBox(height: 12),
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
