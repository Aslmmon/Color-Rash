import 'package:color_rash/presentation/game/game_screen.dart';
import 'package:color_rash/presentation/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'domain/game_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Get the monitoring service instance from the provider scope
    // This requires creating a temporary ProviderContainer for initial setup
    final container = ProviderContainer();
    final appMonitoringService = container.read(appMonitoringServiceProvider);
    await appMonitoringService.initialize();
    FlutterError.onError =
        appMonitoringService.recordFlutterFatalError; // <--- MODIFIED

    // Mobile Ads initialization
    MobileAds.instance.initialize();
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      showPerformanceOverlay: true,
      title: 'Color Rash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // <-- Use your custom theme here
      home: const GameScreen(), // <-- Updated this line
    );
  }
}
