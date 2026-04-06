import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPhoneKeypad = false;
  String _scoreMethod = '秒間正解数';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPhoneKeypad = prefs.getBool('isPhoneKeypad') ?? false;
      _scoreMethod = prefs.getString('scoreMethod') ?? '秒間正解数';
    });
  }

  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPhoneKeypad', value);
    setState(() {
      _isPhoneKeypad = value;
    });
  }

  Future<void> _saveScoreMethod(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scoreMethod', value);
    setState(() {
      _scoreMethod = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '設定',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF544275), // 濃い紫
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF544275)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.dialpad, color: Color(0xFF544275)),
                          const SizedBox(width: 8),
                          const Text(
                            '数字キーパッドの配置',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF544275),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<bool>(
                        title: const Text('電話型 (上が 1 2 3)'),
                        value: true,
                        groupValue: _isPhoneKeypad,
                        activeColor: const Color(0xFF544275),
                        onChanged: (bool? value) {
                          if (value != null) _saveSettings(value);
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text('電卓型 (上が 7 8 9)（デフォルト）'),
                        value: false,
                        groupValue: _isPhoneKeypad,
                        activeColor: const Color(0xFF544275),
                        onChanged: (bool? value) {
                          if (value != null) _saveSettings(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calculate, color: Color(0xFF544275)),
                          const SizedBox(width: 8),
                          const Text(
                            'スコア計算方法',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF544275),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<String>(
                        title: const Text('正解数'),
                        subtitle: const Text('100点満点で評価します'),
                        value: '正解数',
                        groupValue: _scoreMethod,
                        activeColor: const Color(0xFF544275),
                        onChanged: (String? value) {
                          if (value != null) _saveScoreMethod(value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('秒間正解数'),
                        subtitle: const Text('1秒あたりに何問解けたかで評価します（デフォルト）'),
                        value: '秒間正解数',
                        groupValue: _scoreMethod,
                        activeColor: const Color(0xFF544275),
                        onChanged: (String? value) {
                          if (value != null) _saveScoreMethod(value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('クリア時間'),
                        subtitle: const Text('かかった時間（秒）で評価します'),
                        value: 'クリア時間',
                        groupValue: _scoreMethod,
                        activeColor: const Color(0xFF544275),
                        onChanged: (String? value) {
                          if (value != null) _saveScoreMethod(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
