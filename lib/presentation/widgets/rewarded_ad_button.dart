// lib/presentation/widgets/rewarded_ad_button.dart
import 'package:color_rash/domain/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ad_service.dart';
import '../../domain/game_constants.dart';
import '../../domain/game_notifier.dart';
import '../theme/app_colors.dart';
import 'game_button.dart';
import 'pulsating_icon.dart';

class RewardedAdButton extends ConsumerStatefulWidget {
  final IAdService adService;
  final GameNotifier gameNotifier;
  final bool showRewardedAdButton;

  const RewardedAdButton({
    super.key,
    required this.adService,
    required this.gameNotifier,
    required this.showRewardedAdButton,
  });

  @override
  _RewardedAdButtonState createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  bool _isLoading = false;

  void _onPressed() async {
    // Set the loading state to true
    setState(() {
      _isLoading = true;
    });

    // Call the ad service, passing a reference to the provider scope
    widget.adService.showRewardedAd(
      () {
        widget.gameNotifier.grantLevelBoost();
        // Ad has been shown and reward earned, so stop loading
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showRewardedAdButton) {
      return const SizedBox.shrink();
    }

    return GameButton(
      width: AppConstants.kRestartButtonWidth * 1.2,
      height: AppConstants.kRestartButtonHeight / 1.5,
      onPressed: _isLoading ? () {} : _onPressed,
      color: AppColors.incorrectTapColor.withOpacity(0.8),
      borderRadius: AppConstants.kControlBtnBorderRadius,
      child:
          _isLoading
              ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryTextColor,
                ),
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PulsatingIcon(
                    icon: Icons.video_collection,
                    color: AppColors.primaryTextColor,
                    size: 25,
                    duration: Duration(milliseconds: 500),
                  ),
                  SizedBox(width: AppConstants.kSmallSpacing),
                  Text(
                    '${AppStrings.watchAdForBoost} ${AppStrings.levelBoostAmount}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),
    );
  }
}
