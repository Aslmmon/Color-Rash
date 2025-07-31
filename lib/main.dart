import 'package:color_rash/presentation/game/game_screen.dart';
import 'package:color_rash/presentation/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'domain/game_notifier.dart';
import 'domain/game_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _prepareEnvironmentIdsVariables();

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final container = ProviderContainer();
    final appMonitoringService = container.read(appMonitoringServiceProvider);
    await appMonitoringService.initialize();
    FlutterError.onError =
        appMonitoringService.recordFlutterFatalError; // <--- MODIFIED
    MobileAds.instance.initialize();
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _prepareEnvironmentIdsVariables() async {
  String envFileName =
      kDebugMode
          ? '.env.dev'
          : '.env.prod'; // Assuming .env is for production in CI/CD.

  if (kDebugMode && !kIsWeb) {
    final RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: <String>[
        'F2386F50E5601E10DD63F1C43F4B26B2',
        // Replace with your actual device hash ID from logs
        // 'ANOTHER_DEVICE_HASH_ID_2', // Add more if you have other test devices
        // For Android emulators, you can sometimes use 'EMULATOR', but it's less reliable
      ],
    );
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  await dotenv.load(fileName: envFileName); // <--- Load your default dev file
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: kDebugMode ? false : false,
      title: 'Color Rash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // <-- Use your custom theme here
      home: const GameScreen(), // <-- Updated this line
    );
  }
}
