// lib/core/ad_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAdService {
  void loadInterstitialAd();

  void showInterstitialAd();

  String getBannerAdUnitId(); // <--- NEW: Method to get banner ID

  void loadRewardedAd(); // Optional Ref for context

  void showRewardedAd(
    Function onUserEarnedReward,
  ); // Callback for when reward is earned

  // Add other ad types if you decide to implement them later
}
