// lib/presentation/widgets/color_input_buttons.dart
import 'package:flutter/material.dart';
import 'package:color_rash/presentation/game/color_rush_game.dart'; // For ColorRushGame
import 'package:color_rash/presentation/widgets/color_button.dart'; // For ColorButton

class ColorInputButtons extends StatelessWidget {
  final List<Color> colors;
  final ColorRushGame game; // Needs the game instance to call attemptCatch
  const ColorInputButtons({
    super.key,
    required this.colors,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: heightOfScreen * 0.05,
          horizontal: 15.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              colors
                  .map(
                    (color) => ColorButton(
                      color: color,
                      onTap: () => game.attemptCatch(color),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
