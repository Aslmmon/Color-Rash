// lib/presentation/widgets/game_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class GameButton extends StatefulWidget {
  final String backgroundSvgPath;
  final Icon? iconData;
  final String? text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color? iconColor;
  final Color? textColor;
  final bool enableContinuousRotation; // <--- NEW: Flag to enable rotation
  final Duration
  rotationDuration; // <--- NEW: Duration for one full rotation cycle

  const GameButton({
    super.key,
    this.backgroundSvgPath = "assets/images/button_background.svg",
    this.iconData,
    this.text,
    required this.onPressed,
    this.width = 70.0,
    this.height = 70.0,
    this.iconColor,
    this.textColor,
    this.enableContinuousRotation = false, // <--- NEW: Default to no rotation
    this.rotationDuration = const Duration(
      seconds: 5,
    ), // <--- NEW: Default rotation speed
  }) : assert(
         iconData != null || text != null,
         'GameButton must have either an iconSvgPath, iconData, or text.',
       );

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with TickerProviderStateMixin {
  // <--- CHANGE to TickerProviderStateMixin (for multiple controllers)
  late AnimationController
  _pressController; // Controller for the press animation
  late Animation<double> _scaleAnimation;

  late AnimationController
  _rotationController; // <--- NEW: Controller for rotation
  late Animation<double> _rotationAnimation; // <--- NEW: Animation for rotation

  @override
  void initState() {
    super.initState();
    // Controller for the press animation
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    // Controller for continuous rotation
    _rotationController = AnimationController(
      // <--- NEW: Initialize rotation controller
      vsync: this,
      duration: widget.rotationDuration, // Use widget's duration
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController); // Rotates from 0 to 1 (full circle)

    if (widget.enableContinuousRotation) {
      // Start rotating if enabled
      _rotationController.repeat(); // Loop the animation continuously
    }
  }

  @override
  void didUpdateWidget(covariant GameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // <--- NEW: Update rotation behavior if parameters change
    if (widget.enableContinuousRotation != oldWidget.enableContinuousRotation ||
        widget.rotationDuration != oldWidget.rotationDuration) {
      if (widget.enableContinuousRotation) {
        _rotationController.duration = widget.rotationDuration;
        _rotationController.repeat();
      } else {
        _rotationController.stop();
        _rotationController.value = 0; // Reset rotation
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rotationController.dispose(); // <--- NEW: Dispose rotation controller
    super.dispose();
  }

  // --- Tap Gesture Handlers (remain the same) ---
  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          // <--- NEW: Use AnimatedBuilder for continuous rotation
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.141592653589793,
              // Convert 0-1 to 0-2π radians
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Svg(widget.backgroundSvgPath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(child: _buildContent()),
              ),
            );
          },
        ),
      ),
    );
  }

  // _buildContent method remains the same here (already extracted)
  Widget _buildContent() {
    if (widget.iconData != null) {
      return widget.iconData ??
          Icon(
            Icons.question_mark,
            size: widget.width * 0.5,
            color: widget.iconColor ?? Colors.white,
          );
    } else if (widget.text != null) {
      return Text(
        widget.text!,
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: widget.height * 0.3,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
