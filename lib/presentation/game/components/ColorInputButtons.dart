// lib/presentation/widgets/color_input_buttons.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Needed for AdSize.banner.height.toDouble()
import 'package:color_rash/domain/game_constants.dart'; // For kButtonBottomPadding
import 'package:color_rash/presentation/game/color_rush_game.dart'; // For ColorRushGame
import 'package:color_rash/presentation/widgets/color_button.dart'; // For ColorButton

class ColorInputButtons extends StatelessWidget {
  final List<Color> colors;
  final ColorRushGame game; // Needs the game instance to call attemptCatch
  final bool isBannerAdLoaded; // To correctly calculate padding

  const ColorInputButtons({
    super.key,
    required this.colors,
    required this.game,
    required this.isBannerAdLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final double bannerAdHeight =
        isBannerAdLoaded ? AdSize.banner.height.toDouble() : 50.0;

    print("banner hight is "+ AdSize.banner.height.toString());
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: !kIsWeb ? bannerAdHeight : 85.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
