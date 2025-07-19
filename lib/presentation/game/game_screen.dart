import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/core/audio_player.dart';
import 'package:flame/game.dart';
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

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final ColorRushGame _game;
  BannerAd? _bannerAd; // <--- NEW
  bool _isBannerAdLoaded = false; // <--- NEW

  @override
  void initState() {
    super.initState();
    // It's good practice to initialize game state/notifier outside build
    // but the `ref.read` calls inside initState are fine.
    // The game instance itself is initialized once.
    final colors = ref.read(colorProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final IAudioPlayer audioPlayer = ref.read(audioPlayerProvider);

    _game = ColorRushGame(
      status: gameNotifier.state.status, // Initial status
      gameColors: colors,
      notifier: gameNotifier,
      audioPlayer: audioPlayer,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    final IAdService adService = ref.read(
      adServiceProvider,
    ); // <--- NEW: Get Ad Service
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
          print('Error loading banner ad: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // <--- NEW: Dispose banner ad when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch game state for UI updates
    final gameState = ref.watch(gameProvider);
    // Read notifier for method calls (avoid watching notifier itself)
    final gameNotifier = ref.read(gameProvider.notifier);
    final colors = ref.read(colorProvider);

    // This updates the Flame game's internal status whenever the Riverpod state changes.
    // It's crucial for Flame to react to UI-driven state changes.
    _game.status = gameState.status;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GameWidget(game: _game), // Flame game rendered here
                // Top UI: Score and High Score Display
                _buildScoreDisplay(context, gameState),
                // Bottom UI: Color Buttons
                _buildColorButtons(colors, _game),
                // Game Over / Start Overlay (conditionally rendered)
                if (gameState.status != GameStatus.playing)
                  _buildGameOverlay(context, gameState, gameNotifier),
              ],
            ),
          ),
          if (_isBannerAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd?.size.width.toDouble(),
              height: _bannerAd?.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  // Extracted method for Score and High Score display
  Widget _buildScoreDisplay(BuildContext context, GameState gameState) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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

  // Extracted method for Color Buttons
  Widget _buildColorButtons(List<Color> colors, ColorRushGame game) {
    final double bannerAdHeight =
        _isBannerAdLoaded ? AdSize.banner.height.toDouble() : 0.0;
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

  // Extracted method for Game Over / Start Overlay
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
              // Use spread operator for multiple widgets
              Text(
                'Game Over',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),
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
