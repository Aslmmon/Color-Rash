// lib/services/google_ad_service.dart
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Used for `Provider`
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart'; // Import the interface

class GoogleAdService implements IAdService {
  InterstitialAd? _interstitialAd;

  @override
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android test ID
          : 'ca-app-pub-3940256099942544/4411468910', // iOS test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  @override
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load a new one for next time
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
          print('Interstitial ad failed to show: $error');
        },
      );
      _interstitialAd!.show();
    }
  }

  // Don't forget to dispose of the ad when this service is no longer needed
  void dispose() {
    _interstitialAd?.dispose();
  }

  @override
  String getBannerAdUnitId() {
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // Android test ID
        : 'ca-app-pub-3940256099942544/2934735716';
  }
}

// Riverpod provider for the GoogleAdService
final adServiceProvider = Provider<IAdService>((ref) {
  final adService = GoogleAdService();
  ref.onDispose(() => adService.dispose()); // Dispose the service when its provider is disposed
  return adService;
});