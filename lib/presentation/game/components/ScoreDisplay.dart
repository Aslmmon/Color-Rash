// lib/presentation/widgets/score_display.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_state.dart'; // For GameState
import 'package:color_rash/presentation/theme/app_colors.dart'; // For AppColors
import 'package:color_rash/domain/game_constants.dart'; // For constants like kLargePadding, kSmallSpacing

class ScoreDisplay extends StatelessWidget {
  final GameState gameState;

  const ScoreDisplay({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kLargePadding), // Using constant
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${gameState.score}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryTextColor,
                fontSize:
                    kIsWeb
                        ? AppConstants.kTextFontSizeInWeb
                        : AppConstants.kTextFontSizeInMobile, // Make it extra big for WIN!
              ),
            ),
            const SizedBox(height:AppConstants. kSmallSpacing), // Using constant
            Text(
              'High Score: ${gameState.highScore}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryTextColor,
                fontSize:
                    kIsWeb
                        ?AppConstants. kTextFontSizeInWeb
                        :AppConstants. kTextFontSizeInMobile, // Make it extra big for WIN!
              ),
            ),
          ],
        ),
      ),
    );
  }
}
