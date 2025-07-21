// lib/services/google_ad_service.dart
import 'dart:io' show Platform; // Still needed for native platform checks
import 'package:flutter/foundation.dart' show kIsWeb; // <--- NEW: Import kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart';

class GoogleAdService implements IAdService {
  InterstitialAd? _interstitialAd;

  // Helper method to get the correct interstitial ad unit ID based on platform
  String _getInterstitialAdUnitId() {
    if (kIsWeb) {
      return ''; // Return empty string for web, as ads won't load
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
    }
    // Fallback for other unsupported native platforms (e.g., desktop)
    return '';
  }

  @override
  void loadInterstitialAd() {
    // Only attempt to load ads on non-web platforms
    if (kIsWeb) {
      print('Interstitial ads not supported on web platform.');
      return;
    }

    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(), // Use the helper method
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
    // Only show ad if not on web
    if (kIsWeb) {
      print('Interstitial ads not supported on web platform.');
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
          print('Interstitial ad failed to show: $error');
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
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test ID
    }
    return '';
  }

  @override
  String getBannerAdUnitId() {
    return _getBannerAdUnitId(); // Use the helper method
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

// Riverpod provider for the GoogleAdService
final adServiceProvider = Provider<IAdService>((ref) {
  final adService = GoogleAdService();
  ref.onDispose(
    () => adService.dispose(),
  ); // Dispose the service when its provider is disposed
  return adService;
});
