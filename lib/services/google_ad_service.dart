// lib/services/google_ad_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/domain/game_constants.dart'; // <--- NEW: Import game_constants

class GoogleAdService implements IAdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd; // <--- NEW: Rewarded Ad instance
  bool _isRewardedAdLoading =
      false; // <--- NEW: To prevent multiple simultaneous loads

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

  String _getRewardedAdUnitId() {
    if (kIsWeb) {
      return '';
    } else if (Platform.isAndroid) {
      return kRewardedAdUnitIdAndroid; // Android TEST ID for Rewarded Ad
    } else if (Platform.isIOS) {
      return kRewardedAdUnitIdiOS; // iOS TEST ID for Rewarded Ad
    }
    return '';
  }

  @override
  void loadRewardedAd() {
    if (kIsWeb || _isRewardedAdLoading || _rewardedAd != null) {
      // Don't load if on web, already loading, or already loaded
      return;
    }
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
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
