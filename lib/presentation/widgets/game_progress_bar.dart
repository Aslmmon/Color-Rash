// lib/presentation/widgets/game_progress_bar.dart
import 'package:flutter/material.dart';

class GameProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color fillColor;
  final Color borderColor; // <--- NEW: Border color
  final double borderWidth; // <--- NEW: Border width

  const GameProgressBar({
    super.key,
    required this.progress,
    this.height = 24.0,
    this.width = 200.0,
    this.borderRadius = 12.0,
    required this.backgroundColor,
    required this.fillColor,
    required this.borderColor, // <--- NEW
    this.borderWidth = 2.0,    // <--- NEW: Default to 2.0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GameProgressBarPainter(
          progress: progress,
          backgroundColor: backgroundColor,
          fillColor: fillColor,
          borderRadius: borderRadius,
          borderColor: borderColor, // <--- NEW
          borderWidth: borderWidth,  // <--- NEW
        ),
      ),
    );
  }
}

// The CustomPainter class that does the drawing
class _GameProgressBarPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color fillColor;
  final double borderRadius;
  final Color borderColor; // <--- NEW
  final double borderWidth; // <--- NEW

  const _GameProgressBarPainter({
    required this.progress,
    required this.backgroundColor,
    required this.fillColor,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the border first (as the bottom layer)
    final borderPaint = Paint()..color = borderColor;
    final RRect borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(borderRRect, borderPaint);

    // 2. Draw the background of the progress bar (slightly inset)
    final backgroundPaint = Paint()..color = backgroundColor;
    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth, borderWidth, size.width - (borderWidth * 2), size.height - (borderWidth * 2)),
      Radius.circular(borderRadius - (borderWidth / 2)),
    );
    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // 3. Draw the progress fill (also slightly inset and with correct width)
    final progressPaint = Paint()..color = fillColor;
    final RRect progressRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth, borderWidth, (size.width - (borderWidth * 2)) * progress.clamp(0.0, 1.0), size.height - (borderWidth * 2)),
      Radius.circular(borderRadius - (borderWidth / 2)),
    );
    canvas.drawRRect(progressRRect, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GameProgressBarPainter oldDelegate) {
    // Only repaint if the progress value has changed
    return oldDelegate.progress != progress;
  }
}