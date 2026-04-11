import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../logic/ad_controllers.dart';

class AdaptiveBannerBottomBar extends StatefulWidget {
  const AdaptiveBannerBottomBar({super.key});

  @override
  State<AdaptiveBannerBottomBar> createState() =>
      _AdaptiveBannerBottomBarState();
}

class _AdaptiveBannerBottomBarState extends State<AdaptiveBannerBottomBar> {
  late final AdaptiveBannerAdController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveBannerAdController()..addListener(_onAdChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    _controller.load(width: width);
  }

  void _onAdChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onAdChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _controller.bannerAd;
    if (!_controller.isReady || ad == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
