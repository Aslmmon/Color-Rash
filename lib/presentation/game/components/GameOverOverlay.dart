import 'package:color_rash/core/ad_service.dart';
import 'package:color_rash/domain/game_constants.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

import '../../../domain/game_provider.dart';
import '../../../domain/game_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_button.dart';

class GameOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;
  final IAdService adService; // <--- NEW: Accept Ad Service

  const GameOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
    required this.adService, // <--- NEW: Make it required
  });

  @override
  Widget build(BuildContext context) {
    // Determine the main overlay text based on game status
    final String mainOverlayText;
    final Color mainOverlayTextColor;
    final double mainOverlayTextSize;

    if (gameState.status == GameStatus.gameOver) {
      mainOverlayText = AppStrings.gameOverTitle;
      mainOverlayTextColor = AppColors.primaryTextColor;
      mainOverlayTextSize =
          kIsWeb ? kHeadlineLargeFontSizeWeb : kHeadlineLargeFontSizeMobile;
    } else if (gameState.status == GameStatus.won) {
      mainOverlayText = AppStrings.youWinTitle;
      mainOverlayTextColor = AppColors.accentColor;
      mainOverlayTextSize =
          kIsWeb ? kWinTitleFontSizeWeb : kWinTitleFontSizeMobile;
    } else {
      // GameStatus.initial
      mainOverlayText = AppStrings.appTitle; // Or a welcome message if you like
      mainOverlayTextColor = AppColors.accentColor;
      mainOverlayTextSize =
          kIsWeb ? kHeadlineLargeFontSizeWeb : kHeadlineLargeFontSizeMobile;
    }

    final bool showRewardedAdButton =
        gameState.status == GameStatus.initial &&
        (gameState.currentLevel <
            kMaxLevel); // Only show if player can still gain levels

    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(
        kGameOverOverlayOpacity,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display main overlay text (Game Over, You Win, or App Title)
            Text(
              mainOverlayText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: mainOverlayTextColor,
                fontSize: mainOverlayTextSize,
              ),
            ),
            const SizedBox(height: kGameOverScoreSpacing),
            // Only show score details if it's game over OR won
            if (gameState.status == GameStatus.gameOver ||
                gameState.status == GameStatus.won) ...[
              const SizedBox(height: kGameOverScoreSpacing),
              Text(
                '${AppStrings.yourScoreLabel} ${gameState.score}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryTextColor,
                  fontSize: kIsWeb ? kTextFontSizeInWeb : kTextFontSizeInMobile,
                ),
              ),
              const SizedBox(height: kGameOverScoreSpacing),
              // Consistent spacing
              Text(
                '${AppStrings.highScoreLabel} ${gameState.highScore}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentColor,
                  fontSize: kIsWeb ? kTextFontSizeInWeb : kTextFontSizeInMobile,
                ),
              ),
              const SizedBox(height: kGameOverHighscoreSpacing),
            ],

            // Primary Play/Restart Button
            GameButton(
              width: kRestartButtonWidth,
              height: kRestartButtonHeight,
              onPressed: () {
                // If it's Game Over or Won, restart the game (pop GameScreen to MainMenu and then MainMenu pushes GameScreen)
                if (gameState.status == GameStatus.gameOver ||
                    gameState.status == GameStatus.won) {
                  gameNotifier
                      .restartGame(); // This sets status to initial, and loads ad
                } else {
                  gameNotifier.startGame(); // Starts the game
                }
              },
              color: AppColors.buttonColor,
              borderRadius: kControlBtnBorderRadius,
              child: Text(
                gameState.status == GameStatus.initial
                    ? AppStrings.startGameButton
                    : AppStrings.playAgainButton,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.buttonTextColor,
                  fontSize: kRestartButtonTextSize,
                ),
              ),
            ),

            // --- Show Tutorial Button (ONLY in Initial State) ---
            if (gameState.status ==
                GameStatus.initial) // <--- NEW VISIBILITY LOGIC
              const SizedBox(height: kDefaultPadding), // Spacing
            if (gameState.status ==
                GameStatus.initial) // <--- NEW VISIBILITY LOGIC
              GameButton(
                width: kRestartButtonWidth,
                height: kRestartButtonHeight / 1.5,
                // Slightly smaller
                onPressed: gameNotifier.restartTutorial,
                color: AppColors.buttonColor.withOpacity(0.7),
                borderRadius: kControlBtnBorderRadius,
                child: Text(
                  AppStrings.showTutorialButton,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.buttonTextColor,
                    fontSize: kRestartButtonTextSize * 0.8,
                  ),
                ),
              ),

            if (showRewardedAdButton) // Use the calculated boolean
              const SizedBox(height: kDefaultPadding),
            if (showRewardedAdButton)
              GameButton(
                width: kRestartButtonWidth,
                height: kRestartButtonHeight,
                // Use a consistent button width
                onPressed: () {
                  adService.showRewardedAd(() {
                    gameNotifier
                        .grantLevelBoost(); // Callback for when reward is earned
                  });
                },
                color: AppColors.correctTapColor.withOpacity(0.8),
                // Distinct color for reward
                borderRadius: kControlBtnBorderRadius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_collection,
                      color: AppColors.primaryTextColor,
                    ),
                    Text(
                      '${AppStrings.watchAdForBoost} ${AppStrings.levelBoostAmount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

            // --- Return to Main Menu Button (ONLY after a game has ended) ---
            if (gameState.status == GameStatus.gameOver ||
                gameState.status == GameStatus.won) // <--- NEW VISIBILITY LOGIC
              const SizedBox(height: kDefaultPadding),
            if (gameState.status == GameStatus.gameOver ||
                gameState.status == GameStatus.won) // <--- NEW VISIBILITY LOGIC
              GameButton(
                width: kRestartButtonWidth,
                height: kRestartButtonHeight / 1.5,
                onPressed: () {
                  gameNotifier
                      .returnToMainMenu(); // Reset game state (to initial)
                },
                color: AppColors.buttonColor.withOpacity(0.6),
                borderRadius: kControlBtnBorderRadius,
                child: Text(
                  "Main Menu",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.buttonTextColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
