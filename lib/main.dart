import 'package:color_rash/presentation/game/game_screen.dart';
import 'package:color_rash/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // <--- NEW: Crucial for plugins
  MobileAds.instance.initialize(); // <--- NEW: Initialize Google Mobile Ads SDK
  // <--- NEW: Set app to full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Optional: Set preferred orientations if your game should only be portrait/landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Rash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // <-- Use your custom theme here
      home: const GameScreen(), // <-- Updated this line
    );
  }
}
