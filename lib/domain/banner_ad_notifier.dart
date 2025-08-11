import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_service.dart';
import 'game_providers.dart';

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
