// lib/presentation/widgets/game_over_state_overlay.dart
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/theme/app_colors.dart';
import 'package:color_rash/presentation/widgets/game_button.dart';

import '../../../domain/game_notifier.dart'; // For GameNotifier
import '../../../domain/game_state.dart'; // For GameState
import '../../core/ad_service.dart'; // For IAdService

class GameOverStateOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;

  const GameOverStateOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // These values were derived from GameOverlay's build method
    final String mainOverlayText = AppStrings.gameOverTitle;
    final Color mainOverlayTextColor = AppColors.primaryTextColor;
    final double mainOverlayTextSize =
        kIsWeb
            ? AppConstants.kHeadlineLargeFontSizeWeb
            : AppConstants.kHeadlineLargeFontSizeMobile;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display "Game Over" text
        Text(
          mainOverlayText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: mainOverlayTextColor,
            fontSize: mainOverlayTextSize,
          ),
        ),

        // Score details
        const SizedBox(height: AppConstants.kGameOverScoreSpacing),
        Text(
          '${AppStrings.yourScoreLabel} ${gameState.score}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryTextColor,
            fontSize:
                kIsWeb
                    ? AppConstants.kTextFontSizeInWeb
                    : AppConstants.kTextFontSizeInMobile,
          ),
        ),
        const SizedBox(height: AppConstants.kGameOverScoreSpacing),
        // Consistent spacing
        Text(
          '${AppStrings.highScoreLabel} ${gameState.highScore}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.accentColor,
            fontSize:
                kIsWeb
                    ? AppConstants.kTextFontSizeInWeb
                    : AppConstants.kTextFontSizeInMobile,
          ),
        ),
        const SizedBox(height: AppConstants.kGameOverHighscoreSpacing),
        // Spacing before button

        // Primary "Play Again" Button
        GameButton(
          width: AppConstants.kRestartButtonWidth,
          height: AppConstants.kRestartButtonHeight,
          onPressed: () {
            gameNotifier.restartGame(); // Sets status to initial, loads ad
          },
          color: AppColors.buttonColor,
          borderRadius: AppConstants.kControlBtnBorderRadius,
          child: Text(
            AppStrings.playAgainButton,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: AppConstants.kRestartButtonTextSize,
            ),
          ),
        ),

        // --- Return to Main Menu Button ---
        const SizedBox(height: AppConstants.kDefaultPadding),
        // Spacing
        GameButton(
          width: AppConstants.kRestartButtonWidth,
          height: AppConstants.kRestartButtonHeight / 1.5,
          // Slightly smaller
          onPressed: () => gameNotifier.returnToMainMenu(),
          color: AppColors.buttonColor.withOpacity(0.6),
          borderRadius: AppConstants.kControlBtnBorderRadius,
          child: Text(
            AppStrings.mainMenuButton,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: AppConstants.kRestartButtonTextSize * 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
