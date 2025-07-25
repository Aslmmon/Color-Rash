// lib/presentation/widgets/pause_overlay.dart
import 'package:color_rash/domain/game_provider.dart';
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
      color: AppColors.gameOverOverlayColor.withOpacity(kPauseOverlayOpacity),
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
                  fontSize:
                  kIsWeb
                      ? kTextFontSizeInWeb : kTextFontSizeInMobile
              ),
            ),
            const SizedBox(height: kPauseOverlaySpacing), // Using constant
            GameButton(
              width: kPauseButtonWidth,
              // Using constant
              height: kPauseButtonHeight,
              // Using constant
              onPressed: gameNotifier.togglePause,
              color: AppColors.buttonColor,
              // Using app theme color
              borderRadius: kControlBtnBorderRadius,
              // Assuming similar style as control buttons
              child: Text(
                'Resume',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Using titleLarge for consistency
                  color: AppColors.primaryTextColor,
                  fontSize: kPauseButtonTextSize, // Using constant
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
