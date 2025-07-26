// lib/presentation/widgets/game_over_overlay.dart

// ... (existing imports)

import 'package:color_rash/domain/game_constants.dart';
import 'package:flutter/cupertino.dart' show BuildContext, StatelessWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/game_provider.dart';
import '../../../domain/game_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_button.dart';

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
    // ... (existing Container, Center, Column setup)

    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(
        kGameOverOverlayOpacity,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // <--- MODIFIED: Display different text based on status
            if (gameState.status == GameStatus.gameOver)
              Text(
                'Game Over',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryTextColor,
                  fontSize:
                      kIsWeb
                          ? kTextFontSizeInWeb
                          : kTextFontSizeInMobile, // Make it extra big for WIN!
                ),
              )
            else if (gameState.status == GameStatus.won) // <--- NEW
              Text(
                'YOU WIN!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.accentColor,
                  // Celebrate with a different color!
                  fontSize:
                      kIsWeb
                          ? kTextFontSizeInWeb
                          : kTextFontSizeInMobile, // Make it extra big for WIN!
                ),
              ),

            // Only show score details if it's game over OR won
            if (gameState.status == GameStatus.gameOver ||
                gameState.status == GameStatus.won) ...[
              const SizedBox(height: kGameOverScoreSpacing),
              Text(
                'Your Score: ${gameState.score}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryTextColor,
                  fontSize:
                      kIsWeb
                          ? kTextFontSizeInWeb
                          : kTextFontSizeInMobile, // Make it extra big for WIN!
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'High Score: ${gameState.highScore}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentColor,
                  fontSize:
                      kIsWeb
                          ? kTextFontSizeInWeb
                          : kTextFontSizeInMobile, // Make it extra big for WIN!
                ),
              ),
              const SizedBox(height: kGameOverHighscoreSpacing),
            ],

            GameButton(
              width: kRestartButtonWidth,
              height: kRestartButtonHeight,
              onPressed: () {
                // Logic to restart applies for both Game Over and Won states
                if (gameState.status == GameStatus.gameOver ||
                    gameState.status == GameStatus.won) {
                  gameNotifier.restartGame();
                } else {
                  gameNotifier.startGame(); // Start the game if initial
                }
              },
              color: AppColors.buttonColor,
              borderRadius: kControlBtnBorderRadius,
              child: Text(
                gameState.status ==
                        GameStatus
                            .initial // Check original status for button text
                    ? 'Start Game'
                    : 'Play Again',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.buttonTextColor,
                  fontSize: kRestartButtonTextSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
