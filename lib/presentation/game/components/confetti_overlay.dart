// lib/presentation/widgets/confetti_overlay.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  // <--- CHANGE to StatefulWidget
  final List<Color> confettiColors;
  final bool showConfetti; // <--- NEW: External control flag

  const ConfettiOverlay({
    super.key,
    required this.confettiColors,
    required this.showConfetti, // <--- NEW
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      // Use a fixed duration for the animation from the controller side,
      // or pass it in as a parameter if it needs to be dynamic.
      // For now, let's assume a default typical confetti burst duration.
      duration: const Duration(seconds: 3), // Example duration for burst
    );

    // Initial check: if it should be showing when first built
    if (widget.showConfetti) {
      _confettiController.play();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    // <--- IMPORTANT: React to widget changes
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti != oldWidget.showConfetti) {
      if (widget.showConfetti) {
        _confettiController.play();
      } else {
        _confettiController.stop();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ConfettiWidget itself is not conditionally rendered here,
    // its playback is controlled by _confettiController.
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        minBlastForce: 20,
        maxBlastForce: 50,
        emissionFrequency: 0.05,
        numberOfParticles: 15,
        gravity: 0.5,
        colors: widget.confettiColors,
        createParticlePath:
            (size) => Path()..addRect(Rect.fromLTWH(0, 0, 10, 10)),
      ),
    );
  }
}
