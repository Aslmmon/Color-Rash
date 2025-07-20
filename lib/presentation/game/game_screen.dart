// lib/presentation/game/game_screen.dart
import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/game_provider.dart';
import '../../domain/game_state.dart';
import '../../services/flame_audio_player.dart';
import '../../services/google_ad_service.dart';
import '../theme/app_colors.dart';
import '../widgets/color_button.dart';
import 'color_rush_game.dart';
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

  // --- Extracted Methods ---

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
      duration: const Duration(seconds: 1),
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
          _buildScoreDisplay(context, gameState),
          _buildColorButtons(colors, _game),
          if (gameState.status != GameStatus.playing)
            _buildGameOverlay(context, gameState, gameNotifier),
          if (gameState.showLevelUpOverlay)
            LevelUpOverlay(level: gameState.currentLevel),
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

  /// Builds the score and high score display at the top of the screen.
  Widget _buildScoreDisplay(BuildContext context, GameState gameState) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32.0), // Use constant here if defined
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${gameState.score}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryTextColor,
              ),
            ),
            Text(
              'High Score: ${gameState.highScore}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the row of color buttons at the bottom of the screen.
  Widget _buildColorButtons(List<Color> colors, ColorRushGame game) {
    final double bannerAdHeight =
        _isBannerAdLoaded ? AdSize.banner.height.toDouble() : 0.0;
    // Consider adding kButtonBottomPadding to game_constants.dart
    final double bottomPadding = 64.0 + bannerAdHeight;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              colors
                  .map(
                    (color) => ColorButton(
                      color: color,
                      onTap: () => game.attemptCatch(color),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  /// Builds the game over / start overlay.
  Widget _buildGameOverlay(
    BuildContext context,
    GameState gameState,
    GameNotifier gameNotifier,
  ) {
    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gameState.status == GameStatus.gameOver) ...[
              Text(
                'Game Over',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20), // Use constant if desired
              Text(
                'Your Score: ${gameState.score}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              Text(
                'High Score: ${gameState.highScore}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.accentColor),
              ),
              const SizedBox(height: 30), // Use constant if desired
            ],
            ElevatedButton(
              onPressed: () {
                if (gameState.status == GameStatus.gameOver) {
                  gameNotifier.restartGame();
                } else {
                  gameNotifier.startGame();
                }
              },
              child: Text(
                gameState.status == GameStatus.initial
                    ? 'Start Game'
                    : 'Play Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
