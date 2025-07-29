// lib/presentation/widgets/game_won_state_overlay.dart
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/theme/app_colors.dart';
import 'package:color_rash/presentation/widgets/game_button.dart';

import '../../../domain/game_provider.dart'; // For GameNotifier
import '../../../domain/game_state.dart'; // For GameState
import '../../core/ad_service.dart'; // For IAdService

class GameWonStateOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;
  final IAdService adService;

  const GameWonStateOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
    required this.adService,
  });

  @override
  Widget build(BuildContext context) {
    // These values were derived from GameOverlay's build method
    final String mainOverlayText = AppStrings.youWinTitle;
    final Color mainOverlayTextColor =
        AppColors.accentColor; // Accent color for WIN!
    final double mainOverlayTextSize =
        kIsWeb ? kWinTitleFontSizeWeb : kWinTitleFontSizeMobile;


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display "YOU WIN!" text
        Text(
          mainOverlayText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: mainOverlayTextColor,
            fontSize: mainOverlayTextSize, // Specific larger size for WIN
          ),
        ),

        // Score details (always shown after a game ends, whether win or lose)
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
            color: AppColors.accentColor, // High score highlighted
            fontSize: kIsWeb ? kTextFontSizeInWeb : kTextFontSizeInMobile,
          ),
        ),
        const SizedBox(height: kGameOverHighscoreSpacing),
        // Spacing before buttons

        // Primary "Play Again" Button
        GameButton(
          width: kRestartButtonWidth,
          height: kRestartButtonHeight,
          onPressed: () {
            gameNotifier.restartGame(); // Sets status to initial, loads ad
          },
          color: AppColors.buttonColor,
          // Standard button color
          borderRadius: kControlBtnBorderRadius,
          child: Text(
            AppStrings.playAgainButton, // "Play Again"
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: kRestartButtonTextSize,
            ),
          ),
        ),
        // --- Return to Main Menu Button ---
        const SizedBox(height: kDefaultPadding),
        // Spacing
        GameButton(
          width: kRestartButtonWidth,
          height: kRestartButtonHeight / 1.5,
          // Slightly smaller
          onPressed: () {
            gameNotifier.returnToMainMenu(); // Reset game state (to initial)
          },
          color: AppColors.buttonColor.withOpacity(0.6),
          // Slightly dimmer
          borderRadius: kControlBtnBorderRadius,
          child: Text(
            AppStrings.mainMenuButton,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: kRestartButtonTextSize * 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
