// lib/services/google_ad_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/domain/game_constants.dart'; // <--- NEW: Import game_constants

class GoogleAdService implements IAdService {
  InterstitialAd? _interstitialAd;

  // Helper method to get the correct interstitial ad unit ID based on platform
  String _getInterstitialAdUnitId() {
    if (kIsWeb) {
      return ''; // Return empty string for web, as ads won't load
    } else if (Platform.isAndroid) {
      return kInterstitialAdUnitIdAndroid; // <--- MODIFIED: Use constant
    } else if (Platform.isIOS) {
      return kInterstitialAdUnitIdiOS; // <--- MODIFIED: Use constant
    }
    return ''; // Fallback for unsupported platforms
  }

  @override
  void loadInterstitialAd() {
    if (kIsWeb) {
      // print('Interstitial ads not supported on web platform.'); // REMOVED debug print
      return;
    }

    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          // print('Interstitial ad loaded.'); // REMOVED debug print
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          // print('Interstitial ad failed to load: $error'); // REMOVED debug print
        },
      ),
    );
  }

  @override
  void showInterstitialAd() {
    if (kIsWeb) {
      // print('Interstitial ads not supported on web platform.'); // REMOVED debug print
      return;
    }
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load a new one for next time
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
          // print('Interstitial ad failed to show: $error'); // REMOVED debug print
        },
      );
      _interstitialAd!.show();
    }
  }

  // Helper method to get the correct banner ad unit ID based on platform
  String _getBannerAdUnitId() {
    if (kIsWeb) {
      return ''; // Return empty string for web
    } else if (Platform.isAndroid) {
      return kBannerAdUnitIdAndroid; // <--- MODIFIED: Use constant
    } else if (Platform.isIOS) {
      return kBannerAdUnitIdiOS; // <--- MODIFIED: Use constant
    }
    return ''; // Fallback
  }

  @override
  String getBannerAdUnitId() {
    return _getBannerAdUnitId();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
