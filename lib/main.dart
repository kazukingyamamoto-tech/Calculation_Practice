import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screen/homaPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );

    return MaterialApp(
      title: '100マス基礎練習',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.notoSansJpTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final mediaQuery = MediaQuery.of(context);
        final size = mediaQuery.size;

        // 横長で報告される端末でも、アプリ内部は常に縦長レイアウトで扱う。
        if (size.height >= size.width) {
          return child;
        }

        final portraitSize = Size(size.height, size.width);
        return MediaQuery(
          data: mediaQuery.copyWith(size: portraitSize),
          child: Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: SizedBox(
                width: portraitSize.width,
                height: portraitSize.height,
                child: child,
              ),
            ),
          ),
        );
      },
      home: const MyHomePage(),
    );
  }
}
