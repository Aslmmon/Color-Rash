// lib/presentation/widgets/game_over_overlay.dart
import 'package:color_rash/domain/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_state.dart'; // For GameState
import 'package:color_rash/presentation/theme/app_colors.dart'; // For AppColors
import 'package:color_rash/presentation/widgets/game_button.dart'; // For GameButton
import 'package:color_rash/domain/game_constants.dart';

class GameOverOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;

  const GameOverOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(
        kGameOverOverlayOpacity,
      ), // Using constant
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
              const SizedBox(height: kGameOverScoreSpacing),
              // Using constant
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
              const SizedBox(height: kGameOverHighscoreSpacing),
              // Using constant
            ],

            GameButton(
              width: kRestartButtonWidth,
              // Using constant
              height: kRestartButtonHeight,
              // Using constant
              onPressed: () {
                if (gameState.status == GameStatus.gameOver) {
                  gameNotifier.restartGame();
                } else {
                  gameNotifier.startGame();
                }
              },
              color: AppColors.buttonColor,
              // Using theme color for the button
              borderRadius: kControlBtnBorderRadius,
              // Using a circular-ish button style from GameControlButtons
              child: Text(
                gameState.status == GameStatus.initial
                    ? 'Start Game'
                    : 'Play Again',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Using titleLarge for consistency
                  color: AppColors.buttonTextColor,
                  fontSize: kRestartButtonTextSize, // Using constant
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
