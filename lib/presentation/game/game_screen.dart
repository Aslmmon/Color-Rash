import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_provider.dart';
import '../../domain/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/color_button.dart';
import 'color_rush_game.dart';

// Convert to a StatefulConsumerWidget
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // Create the game instance here
  late final ColorRushGame _game;

  @override
  void initState() {
    super.initState();
    // Get the colors and notifier from Riverpod
    final colors = ref.read(colorProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Create the game instance and pass the notifier to it
    _game = ColorRushGame(
      status: gameNotifier.state.status,
      gameColors: colors,
      notifier: gameNotifier, // Pass the notifier
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final colors = ref.read(colorProvider);

    // Tell the game instance what the current status is
    _game.status = gameState.status;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          Align(
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
                    ), // Use theme and AppColors
                  ),
                  Text(
                    'High Score: ${gameState.highScore}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryTextColor,
                    ), // Use theme and AppColors
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    colors
                        .map(
                          (color) => ColorButton(
                            color: color,
                            onTap: () => _game.attemptCatch(color),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),

          if (gameState.status != GameStatus.playing)
            Container(
              color: AppColors.gameOverOverlayColor.withOpacity(0.5),
              // Use AppColors
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (gameState.status == GameStatus.gameOver)
                      Text(
                        'Game Over',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primaryTextColor,
                        ), // Use AppColors
                      ),
                    if (gameState.status == GameStatus.gameOver)
                      const SizedBox(height: 20),
                    if (gameState.status == GameStatus.gameOver)
                      Text(
                        'Your Score: ${gameState.score}',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryTextColor,
                        ), // Use theme and AppColors
                      ),
                    if (gameState.status == GameStatus.gameOver)
                      Text(
                        'High Score: ${gameState.highScore}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accentColor,
                        ), // Use theme and AppColors
                      ),
                    if (gameState.status == GameStatus.gameOver)
                      const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (gameState.status == GameStatus.gameOver) {
                          gameNotifier.restartGame();
                        } else {
                          gameNotifier.startGame();
                        }
                      },
                      // No need to set style here, it's defined in AppTheme.darkTheme.elevatedButtonTheme
                      child: Text(
                        gameState.status == GameStatus.initial
                            ? 'Start Game'
                            : 'Play Again',
                        // No need to set style here directly if ElevatedButtonThemeData is configured
                        // If you want to override: style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],

                ),
              ),
            ),
        ],
      ),
    );
  }
}
