// lib/services/google_ad_service.dart
import 'package:color_rash/domain/game_providers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart';

class GoogleAdService implements IAdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd; // <--- NEW: Rewarded Ad instance
  bool _isRewardedAdLoading =
      false; // <--- NEW: To prevent multiple simultaneous loads

  String _getAdmobAppId() => dotenv.env['ADMOB_APP_ID'] ?? '';

  String _getBannerId() => dotenv.env['ADMOB_BANNER_ID'] ?? '';

  String _getInterstitialId() => dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';

  String _getRewardedId() => dotenv.env['ADMOB_REWARDED_ID'] ?? '';

  // Helper method to get the correct interstitial ad unit ID based on platform

  @override
  void loadInterstitialAd() {
    if (kIsWeb) {
      // print('Interstitial ads not supported on web platform.'); // REMOVED debug print
      return;
    }

    InterstitialAd.load(
      adUnitId: _getInterstitialId(),
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

  @override
  String getBannerAdUnitId() {
    return _getBannerId();
  }

  @override
  void loadRewardedAd() {
    if (kIsWeb || _isRewardedAdLoading || _rewardedAd != null) {
      // Don't load if on web, already loading, or already loaded
      return;
    }
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: _getRewardedId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;

          print('Rewarded ad loaded.'); // Debugging
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          print('Rewarded ad failed to load: $error'); // Debugging
        },
      ),
    );
  }

  @override
  void showRewardedAd(Function onUserEarnedReward) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd(); // Load the next one for future use
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
          print('Rewarded ad failed to show: $error'); // Debugging
        },
      );
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(); // Call the callback provided by GameNotifier
        },
      );
    } else {
      print('Rewarded ad not loaded yet.'); // Debugging
      loadRewardedAd(); // Try to load if it's null
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose(); // <--- NEW: Dispose rewarded ad too
  }
}
