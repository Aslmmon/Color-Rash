import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_constants.dart'; // Ensure this is imported

class ColorButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorButton({super.key, required this.color, required this.onTap});

  @override
  State<ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(
        milliseconds: AppConstants.kButtonPressAnimationDurationMs,
      ),
      // Duration of the animation
      lowerBound: 0.0,
      // Minimum value of the animation (for reverse)
      upperBound: 1.0, // Maximum value of the animation (for forward)
    );

    // Define the scale animation: shrinks to 90% size when pressed
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppConstants.kButtonPressScaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  // --- New Methods to Handle Tap Gestures ---
  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // Start animation to shrink the button
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse(); // Animate back to original size
    widget.onTap(); // Call the original onTap callback
  }

  void _onTapCancel() {
    _controller
        .reverse(); // If tap is cancelled (e.g., finger slides off), revert animation
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: AppConstants.kObjectRadius * 2,
          height: AppConstants.kObjectRadius * 2,
          decoration: BoxDecoration(
            color: widget.color, // Use widget.color
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: AppConstants.kColorButtonBorderWidth,
            ), // Border width could be a constant
          ),
        ),
      ),
    );
  }
}
