// lib/presentation/widgets/level_up_overlay.dart
import 'package:color_rash/domain/game_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:color_rash/presentation/theme/app_colors.dart'; // For colors

class LevelUpOverlay extends StatefulWidget {
  final int level;

  const LevelUpOverlay({super.key, required this.level});

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Animation duration
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL ${widget.level}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.accentColor, // Use accent color for pop
                  fontSize:
                      kIsWeb
                          ? AppConstants.kTextFontSizeInWeb
                          : AppConstants.kTextFontSizeInMobile,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: AppColors.accentColor.withOpacity(0.8),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              Text(
                'Difficulty Increased!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
