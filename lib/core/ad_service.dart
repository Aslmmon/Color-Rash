// lib/core/ad_service.dart
abstract class IAdService {
  void loadInterstitialAd();
  void showInterstitialAd();
  String getBannerAdUnitId(); // <--- NEW: Method to get banner ID

// Add other ad types if you decide to implement them later
}