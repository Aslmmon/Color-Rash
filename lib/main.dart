import 'package:color_rash/presentation/game/game_screen.dart';
import 'package:color_rash/presentation/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'domain/game_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String envFileName =
      kDebugMode
          ? '.env.dev'
          : '.env.prod'; // Assuming .env is for production in CI/CD.

  debugPrint("environemtFileUsed is + " + envFileName.toString());

  // Only apply this in debug builds
  final RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: <String>[
      'F2386F50E5601E10DD63F1C43F4B26B2',
      // Replace with your actual device hash ID from logs
      // 'ANOTHER_DEVICE_HASH_ID_2', // Add more if you have other test devices
      // For Android emulators, you can sometimes use 'EMULATOR', but it's less reliable
    ],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);
  debugPrint('AdMob: Test devices configured programmatically.');

  await dotenv.load(fileName: envFileName); // <--- Load your default dev file

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
