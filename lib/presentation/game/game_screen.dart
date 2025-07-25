import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/game_constants.dart';
import '../../domain/game_provider.dart';
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

class _GameScreenState extends ConsumerState<GameScreen> {
  late final ColorRushGame _game;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    final colors = ref.read(colorProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final IAudioPlayer audioPlayer = ref.read(audioPlayerProvider);

    _game = ColorRushGame(
      status: gameNotifier.state.status,
      gameColors: colors,
      notifier: gameNotifier,
      audioPlayer: audioPlayer,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        _loadBannerAd();
      } else {
        // print('Banner ads not supported on web platform.'); // Removed debug print
      }
    });
  }

  void _loadBannerAd() {
    final IAdService adService = ref.read(adServiceProvider);
    _bannerAd = BannerAd(
      adUnitId: adService.getBannerAdUnitId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdLoaded = false;
          ad.dispose();
          // print('Error loading banner ad: $err'); // Removed debug print
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final colors = ref.read(colorProvider);

    _game.status = gameState.status; // Update Flame game status
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
    final List<Color> currentGradientColors =
        AppColors.backgroundGradients[gameState.currentGradientIndex];

    return AnimatedContainer(
      duration: const Duration(seconds: kBackgroundGradientChangeDurationMs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentGradientColors,
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
    return Expanded(
      child: Stack(
        children: [
          GameWidget(game: _game), // Flame game rendered here
          ScoreDisplay(gameState: gameState),
          GameControlButtons(gameState: gameState, gameNotifier: gameNotifier),
          ColorInputButtons(
            colors: colors,
            game: _game, // Pass the game instance
            isBannerAdLoaded: _isBannerAdLoaded, // Pass the flag
          ),
          if (gameState.status != GameStatus.playing)
            GameOverOverlay(gameState: gameState, gameNotifier: gameNotifier),
          if (gameState.showLevelUpOverlay)
            LevelUpOverlay(level: gameState.currentLevel),
          if (gameState.isPaused) // Show the pause overlay only when paused
            PauseOverlay(gameNotifier: gameNotifier),

          ConfettiOverlay(
            confettiColors:
                AppColors.backgroundGradients.expand((list) => list).toList(),
            showConfetti:
                gameState.showConfetti, // <--- Pass the state directly
          ),
        ],
      ),
    );
  }

  /// Builds the section for displaying the banner ad.
  Widget _buildBannerAdSection() {
    if (!kIsWeb && _isBannerAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd?.size.width.toDouble(),
        height: _bannerAd?.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink(); // Hide if not loaded or on web
  }
}
