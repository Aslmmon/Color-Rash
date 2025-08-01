// lib/presentation/widgets/game_control_buttons.dart
import 'package:color_rash/domain/game_notifier.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_state.dart'; // For GameState
import 'package:color_rash/presentation/theme/app_colors.dart'; // For AppColors
import 'package:color_rash/presentation/widgets/game_button.dart'; // For GameButton
import 'package:color_rash/domain/game_constants.dart'; // For constants like kControlButtonSize

class GameControlButtons extends StatelessWidget {
  final GameState
  gameState; // Pass the whole state for now for simplicity, but can be granularized
  final GameNotifier gameNotifier;

  const GameControlButtons({
    super.key,
    required this.gameState,
    required this.gameNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppConstants.kDefaultPadding, // Using constant
      left: AppConstants.kDefaultPadding, // Using constant
      right: AppConstants.kDefaultPadding, // Using constant
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GameButton(
            onPressed: gameNotifier.togglePause,
            width: AppConstants.kControlButtonSize,
            height: AppConstants.kControlButtonSize,
            borderRadius: AppConstants.kControlBtnBorderRadius,
            child: Icon(
              gameState.isPaused ? Icons.play_arrow : Icons.pause,
              color: AppColors.buttonTextColor,
              size: AppConstants.kControlButtonIconSize,
            ),
          ),
          GameButton(
            onPressed: gameNotifier.toggleMute,
            width: AppConstants.kControlButtonSize,
            height: AppConstants.kControlButtonSize,
            borderRadius: AppConstants.kControlBtnBorderRadius,
            child: Icon(
              gameState.isMuted ? Icons.volume_off : Icons.volume_up,
              color: AppColors.buttonTextColor,
              size: AppConstants.kControlButtonIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
