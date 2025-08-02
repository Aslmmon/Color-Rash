// lib/presentation/widgets/pulsating_icon.dart
import 'package:flutter/material.dart';

class PulsatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;

  const PulsatingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24.0, // Default size
    this.duration = const Duration(
      seconds: 1,
    ), // Default duration for one pulse cycle
  });

  @override
  State<PulsatingIcon> createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Creates a scale animation that goes from 1.0 (full size) to 1.1 (10% larger) and back.
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));

    _controller.repeat(
      reverse: true,
    ); // Loop the animation continuously, scaling back and forth
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
