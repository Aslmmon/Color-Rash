import 'package:flutter/material.dart';

import '../../domain/game_constants.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorButton({
    super.key,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kObjectRadius * 2, // <--- MODIFIED: Use constant for size based on object radius
        height: kObjectRadius * 2,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}