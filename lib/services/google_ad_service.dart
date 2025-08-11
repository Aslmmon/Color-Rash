// lib/services/google_ad_service.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:color_rash/core/ad_service.dart';

import '../domain/game_providers.dart';

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
  void loadRewardedAd({Ref? ref}) {
    if (kIsWeb || _isRewardedAdLoading || _rewardedAd != null) {
      // Don't load if on web, already loading, or already loaded
      return;
    }
    _isRewardedAdLoading = true;
    ref?.read(rewardedAdLoadingProvider.notifier).state =
        true; // Update loading state

    RewardedAd.load(
      adUnitId: _getRewardedId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          ref?.read(rewardedAdLoadingProvider.notifier).state =
              false; // Update loading state

          print('Rewarded ad loaded.'); // Debugging
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          ref?.read(rewardedAdLoadingProvider.notifier).state =
              false; // Update loading state
          print('Rewarded ad failed to load: $error'); // Debugging
        },
      ),
    );
  }

  @override
  void showRewardedAd(Function onUserEarnedReward) {
    debugPrint("Showing rewarded ad..." + _rewardedAd.toString()); // Debugging
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
        },
      );
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(); // Call the callback provided by GameNotifier
        },
      );
    } else {
      print('Rewarded ad not loaded yet.'); // Debugging
      loadRewardedAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose(); // <--- NEW: Dispose rewarded ad too
  }
}

/**
 * Banner Ad Provider uses Riverpod to manage the state of the banner ad.
 */
class BannerAdState {
  final BannerAd? bannerAd;
  final bool isLoaded;

  BannerAdState({this.bannerAd, this.isLoaded = false});
}

final bannerAdProvider = StateNotifierProvider<BannerAdNotifier, BannerAdState>(
  (ref) {
    final adService = ref.watch(adServiceProvider);
    return BannerAdNotifier(adService);
  },
);

class BannerAdNotifier extends StateNotifier<BannerAdState> {
  final IAdService _adService;

  BannerAdNotifier(this._adService) : super(BannerAdState()) {
    _loadBannerAd();
  }

  void _loadBannerAd() {
    BannerAd(
      adUnitId: _adService.getBannerAdUnitId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          state = BannerAdState(bannerAd: ad as BannerAd, isLoaded: true);
        },
        onAdFailedToLoad: (ad, err) {
          state = BannerAdState();
          ad.dispose();
        },
      ),
    ).load();
  }

  // Reload the ad, perhaps for a new game session
  void reloadAd() {
    state.bannerAd?.dispose();
    state = BannerAdState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    state.bannerAd?.dispose();
    super.dispose();
  }
}
