import 'package:flutter/material.dart';
import 'package:color_rash/domain/game_constants.dart'; // Ensure this is imported

class ColorButton extends StatefulWidget {
  // <--- CHANGE to StatefulWidget
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
      duration: const Duration(milliseconds: 150), // Duration of the animation
      lowerBound: 0.0, // Minimum value of the animation (for reverse)
      upperBound: 1.0, // Maximum value of the animation (for forward)
    );

    // Define the scale animation: shrinks to 90% size when pressed
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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
      // <--- Use new tap down handler
      onTapUp: _onTapUp,
      // <--- Use new tap up handler
      onTapCancel: _onTapCancel,
      // <--- Use new tap cancel handler
      // IMPORTANT: Remove the direct onTap: widget.onTap, otherwise it will fire twice or conflict
      // The actual widget.onTap() call is now within _onTapUp()
      child: ScaleTransition(
        // <--- Wrap with ScaleTransition
        scale: _scaleAnimation,
        child: Container(
          width: kObjectRadius * 2,
          height: kObjectRadius * 2,
          decoration: BoxDecoration(
            color: widget.color, // Use widget.color
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ), // Border width could be a constant
          ),
        ),
      ),
    );
  }
}
