import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:color_rash/domain/banner_ad_notifier.dart';
import 'package:color_rash/presentation/widgets/tutorial_overlay.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/game_constants.dart';
import '../../domain/game_notifier.dart';
import '../../domain/game_providers.dart';
import '../../domain/game_state.dart';
import '../theme/app_colors.dart';
import 'color_rush_game.dart';
import 'components/ColorInputButtons.dart';
import 'components/GameControlButtons.dart';
import 'components/GameOverOverlay.dart';
import 'components/PauseOverlay.dart';
import 'components/ScoreDisplay.dart';
import 'components/confetti_overlay.dart';
import 'components/level_up_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  late final ColorRushGame _game;

  // BannerAd? _bannerAd;

  // bool _isBannerAdLoaded = false;
  late final IAdService _adService;
  static final List<Color> _allConfettiColors =
      AppColors.backgroundGradients.expand((list) => list).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <--- REGISTER Observer

    final colors = ref.read(colorProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final IAudioPlayer audioPlayer = ref.read(audioPlayerProvider);
    _adService = ref.read(adServiceProvider);

    _game = ColorRushGame(
      status: gameNotifier.state.status,
      gameColors: colors,
      notifier: gameNotifier,
      audioPlayer: audioPlayer,
    );
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!kIsWeb) {
    //     _loadBannerAd();
    //   }
    // });
  }

  // void _loadBannerAd() {
  //   _bannerAd = BannerAd(
  //     adUnitId: _adService.getBannerAdUnitId(),
  //     request: const AdRequest(),
  //     size: AdSize.banner,
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         setState(() {
  //           _isBannerAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, err) {
  //         _isBannerAdLoaded = false;
  //         ad.dispose();
  //         // print('Error loading banner ad: $err'); // Removed debug print
  //       },
  //     ),
  //   )..load();
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <--- UNREGISTER Observer
    // _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final colors = ref.read(colorProvider);
    _game.status = gameState.status; // Update Flame game status
    debugPrint(
      "GameScreen initialized with game status: ${gameNotifier.state.toString()}",
    );

    return Scaffold(
      body: _buildBackgroundGradient(context, gameState, gameNotifier, colors),
    );
  }

  /// Builds the animated container with the dynamic gradient background.
  Widget _buildBackgroundGradient(
    BuildContext context,
    GameState gameState,
    GameNotifier gameNotifier,
    List<Color> colors,
  ) {
    return AnimatedContainer(
      duration: const Duration(
        seconds: AppConstants.kBackgroundGradientChangeDurationMs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradients[gameState.currentGradientIndex],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildGameContentStack(context, gameState, gameNotifier, colors),
          _buildBannerAdSection(),
        ],
      ),
    );
  }

  /// Builds the main game content area, including the Flame game and UI overlays.
  Widget _buildGameContentStack(
    BuildContext context,
    GameState gameState,
    GameNotifier gameNotifier,
    List<Color> colors,
  ) {
    debugPrint('GameState: $gameState');
    return Expanded(
      child: Stack(
        children: [
          GameWidget(game: _game),
          ScoreDisplay(gameState: gameState),
          GameControlButtons(gameState: gameState, gameNotifier: gameNotifier),
          ColorInputButtons(colors: colors, game: _game),
          if (gameState.status != GameStatus.playing)
            GameOverlay(
              gameState: gameState,
              gameNotifier: gameNotifier,
              adService: _adService,
            ),
          if (gameState.showLevelUpOverlay)
            LevelUpOverlay(level: gameState.currentLevel),
          if (gameState.isPaused) // Show the pause overlay only when paused
            PauseOverlay(gameNotifier: gameNotifier),
          ConfettiOverlay(
            confettiColors: _allConfettiColors,
            showConfetti:
                gameState.showConfetti, // <--- Pass the state directly
          ),
          if (gameState.status == GameStatus.initial &&
              !gameState.hasSeenTutorial)
            TutorialOverlay(gameNotifier: gameNotifier),
        ],
      ),
    );
  }

  /// Builds the section for displaying the banner ad.
  Widget _buildBannerAdSection() {
    final adState = ref.watch(bannerAdProvider);
    if (!kIsWeb && adState.isLoaded) {
      return SizedBox(
        width: adState.bannerAd?.size.width.toDouble(),
        height: adState.bannerAd?.size.height.toDouble(),
        child: AdWidget(ad: adState.bannerAd!),
      );
    }

    return SizedBox(height: 50,width: 50);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gameNotifier = ref.read(gameProvider.notifier);
    switch (state) {
      case AppLifecycleState
          .paused: // App is in the background or screen is locked
        if (!gameNotifier.state.isPaused &&
            gameNotifier.state.status == GameStatus.playing) {
          gameNotifier
              .togglePause(); // Pause the game if it's playing and not already paused
        }
        break;
      case AppLifecycleState.resumed: // App comes to foreground
        break;
      case AppLifecycleState
          .inactive: // Temporary pause, e.g., incoming call. Often behaves like paused.
        if (!gameNotifier.state.isPaused &&
            gameNotifier.state.status == GameStatus.playing) {
          gameNotifier.togglePause();
        }
        break;
      case AppLifecycleState.detached: // App is terminated
        break;
      case AppLifecycleState.hidden: // App is hidden (iOS 16+ or Android 13+)
        if (!gameNotifier.state.isPaused &&
            gameNotifier.state.status == GameStatus.playing) {
          gameNotifier.togglePause();
        }
        break;
    }
  }
}
