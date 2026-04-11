import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdaptiveBannerAdController extends ChangeNotifier {
  BannerAd? _bannerAd;
  bool _isReady = false;
  int _lastWidth = 0;
  bool _disposed = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isReady => _isReady;

  String get _adUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
      default:
        return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  void load({required int width}) {
    if (_disposed || width <= 0 || kIsWeb) {
      return;
    }

    if (width == _lastWidth && _bannerAd != null) {
      return;
    }

    _lastWidth = width;

    const adSize = AdSize.largeBanner;

    final ad = BannerAd(
      adUnitId: _adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }

          _bannerAd?.dispose();
          _bannerAd = ad as BannerAd;
          _isReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (_disposed) {
            return;
          }

          _isReady = false;
          notifyListeners();
        },
      ),
    );

    ad.load();
  }

  @override
  void dispose() {
    _disposed = true;
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }
}

class InterstitialAdController {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _disposed = false;

  String get _adUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/4411468910';
      default:
        return 'ca-app-pub-3940256099942544/1033173712';
    }
  }

  void load() {
    if (_disposed || _isLoading || _interstitialAd != null || kIsWeb) {
      return;
    }

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }

          _isLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showThen(VoidCallback onAfterAd) {
    final ad = _interstitialAd;
    if (ad == null) {
      onAfterAd();
      load();
      return;
    }

    _interstitialAd = null;
    var finished = false;

    void finishOnce() {
      if (finished) {
        return;
      }
      finished = true;
      onAfterAd();
      load();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        finishOnce();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        finishOnce();
      },
    );

    ad.show();
  }

  void dispose() {
    _disposed = true;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
