// lib/presentation/widgets/pause_overlay.dart
import 'package:color_rash/domain/game_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/presentation/theme/app_colors.dart'; // For AppColors
import 'package:color_rash/presentation/widgets/game_button.dart'; // For GameButton
import 'package:color_rash/domain/game_constants.dart'; // For constants

class PauseOverlay extends StatelessWidget {
  final GameNotifier gameNotifier;

  const PauseOverlay({super.key, required this.gameNotifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(AppConstants.kPauseOverlayOpacity),
      // Using constant for opacity
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Paused',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                // Using headlineLarge for consistency
                color: AppColors.primaryTextColor,
                fontSize: kIsWeb ? AppConstants.kTextFontSizeInWeb :AppConstants. kTextFontSizeInMobile,
              ),
            ),
            const SizedBox(height: AppConstants.kPauseOverlaySpacing), // Using constant
            GameButton(
              width: AppConstants.kPauseButtonWidth,
              // Using constant
              height: AppConstants.kPauseButtonHeight,
              // Using constant
              onPressed: gameNotifier.togglePause,
              color: AppColors.accentColor,
              // Using app theme color
              borderRadius: AppConstants.kControlBtnBorderRadius,
              // Assuming similar style as control buttons
              child: Text(
                'Resume',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Using titleLarge for consistency
                  color: AppColors.primaryTextColor,
                  fontSize: AppConstants.kPauseButtonTextSize, // Using constant
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
