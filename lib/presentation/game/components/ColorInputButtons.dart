// lib/presentation/widgets/color_input_buttons.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Needed for AdSize.banner.height.toDouble()
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 70.0, horizontal: 20.0),
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
