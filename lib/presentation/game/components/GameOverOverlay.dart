import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/widgets/game_over_state_overlay.dart';
import 'package:color_rash/presentation/widgets/game_won_state_overlay.dart';
import 'package:color_rash/presentation/widgets/initial_game_overlay.dart';
import 'package:flutter/material.dart';

import 'package:color_rash/core/ad_service.dart'; // Ensure IAdService is imported
import '../../../domain/game_notifier.dart';
import '../../../domain/game_state.dart';
import '../../theme/app_colors.dart';

class GameOverlay extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameNotifier;
  final IAdService adService;

  const GameOverlay({
    super.key,
    required this.gameState,
    required this.gameNotifier,
    required this.adService,
  });

  @override
  Widget build(BuildContext context) {
    // The Container and Center are common to all overlays, so they stay here.
    return Container(
      color: AppColors.gameOverOverlayColor.withOpacity(
        AppConstants. kGameOverOverlayOpacity,
      ),
      child: Center(
        child: _buildOverlayContent(
          context,
        ), // <--- NEW: Delegate content building
      ),
    );
  }

  // <--- NEW: Method to dispatch to the correct overlay content widget
  Widget _buildOverlayContent(BuildContext context) {
    switch (gameState.status) {
      case GameStatus.initial:
        return InitialStateOverlay(
          gameState: gameState,
          gameNotifier: gameNotifier,
          adService: adService,
        );
      case GameStatus.gameOver:
        return GameOverStateOverlay(
          gameState: gameState,
          gameNotifier: gameNotifier,
        );
      case GameStatus.won:
        return GameWonStateOverlay(
          gameState: gameState,
          gameNotifier: gameNotifier,
        );
      case GameStatus.playing:
        // GameOverlay is typically not visible when status is playing,
        // but if it somehow is, return an empty widget or log an error.

        return const SizedBox.shrink();
    }
  }
}
