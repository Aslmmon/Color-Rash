// lib/presentation/widgets/initial_game_overlay.dart
import 'package:color_rash/domain/game_providers.dart';
import 'package:color_rash/presentation/widgets/pulsating_icon.dart'
    show PulsatingIcon;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/theme/app_colors.dart';
import 'package:color_rash/presentation/widgets/game_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/game_notifier.dart'; // For GameNotifier
import '../../../domain/game_state.dart'; // For GameState
import '../../core/ad_service.dart';

class InitialStateOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;
  final IAdService adService;

  const InitialStateOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
    required this.adService,
  });

  @override
  Widget build(BuildContext context) {
    // These values were previously calculated in GameOverlay
    final String mainOverlayText = AppStrings.appTitle;
    final Color mainOverlayTextColor = AppColors.accentColor;
    final double mainOverlayTextSize =
        kIsWeb
            ? AppConstants.kHeadlineLargeFontSizeWeb
            : AppConstants.kHeadlineLargeFontSizeMobile;
    final String startLevelHintText =
        '${AppStrings.startLevelHint} ${gameState.startLevelOverride ?? 1}';

    // Logic for showing Rewarded Ad button in initial state
    final bool showRewardedAdButton =
        (gameState.currentLevel < AppConstants.kMaxLevel);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display main overlay text (App Title)
        Text(
          mainOverlayText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: mainOverlayTextColor,
            fontSize: mainOverlayTextSize,
          ),
        ),

        const SizedBox(height: AppConstants.kGameOverScoreSpacing),
        // Spacing before button
        // Primary Start Game Button
        GameButton(
          width: AppConstants.kRestartButtonWidth,
          height: AppConstants.kRestartButtonHeight,
          onPressed: () {
            gameNotifier.startGame(); // Starts the game
          },
          color: AppColors.buttonColor,
          borderRadius: AppConstants.kControlBtnBorderRadius,
          child: Text(
            AppStrings.startGameButton,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: AppConstants.kRestartButtonTextSize,
            ),
          ),
        ),

        // --- Show Tutorial Button ---
        const SizedBox(height: AppConstants.kDefaultPadding),
        // Spacing
        GameButton(
          width: AppConstants.kRestartButtonWidth,
          height: AppConstants.kRestartButtonHeight / 1.5,
          // Slightly smaller
          onPressed: gameNotifier.restartTutorial,
          color: AppColors.buttonColor.withOpacity(0.7),
          borderRadius: AppConstants.kControlBtnBorderRadius,
          child: Text(
            AppStrings.showTutorialButton,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.buttonTextColor,
              fontSize: AppConstants.kRestartButtonTextSize * 0.8,
            ),
          ),
        ),

        // --- Rewarded Ad Button ---
        if (showRewardedAdButton) // Use the calculated boolean
          const SizedBox(height: AppConstants.kDefaultPadding),
        if (showRewardedAdButton)
          Column(
            children: [
              GameButton(
                width: AppConstants.kRestartButtonWidth * 1.2,
                height: AppConstants.kRestartButtonHeight / 1.5,
                // Consistent with tutorial button
                onPressed: () {
                  // We now need to pass the ref to the adService methods
                  adService.showRewardedAd(
                    () => gameNotifier.grantLevelBoost(),
                  );
                },
                color: AppColors.incorrectTapColor.withOpacity(0.8),
                borderRadius: AppConstants.kControlBtnBorderRadius,
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulsatingIcon(
                      icon: Icons.video_collection,
                      color: AppColors.primaryTextColor,
                      size: 25,
                      // You can adjust the duration here if you want a faster/slower pulse
                      duration: const Duration(
                        milliseconds: 500,
                      ), // Example: a 2-second pulse cycle
                    ),
                    SizedBox(height: AppConstants.kSmallSpacing),
                    // Spacing between icon and text
                    Text(
                      '${AppStrings.watchAdForBoost} ${AppStrings.levelBoostAmount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Start Level Hint Text
              const SizedBox(height: AppConstants.kDefaultPadding), // Spacing
              Text(
                startLevelHintText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
