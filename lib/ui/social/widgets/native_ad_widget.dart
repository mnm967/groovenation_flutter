import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../ad_helper.dart';

class NativeAdWidget extends StatefulWidget{
  final _NativeAdWidgetState state = _NativeAdWidgetState();

  @override
  _NativeAdWidgetState createState() {
    return state;
  }
}

class _NativeAdWidgetState extends State<NativeAdWidget>{

  late NativeAd _ad;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'lt',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');       },
      ),
    );
    _ad.load();

  }

  @override
  void dispose() {
    super.dispose();
    _ad.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded ? Container(
      child: AdWidget(ad: _ad),
      height: 356.0,
      padding: EdgeInsets.only(left: 18, right: 18, bottom: 24),
      alignment: Alignment.center,
    ) : Container();
  }

}