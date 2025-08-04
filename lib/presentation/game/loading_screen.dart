import 'package:color_rash/domain/game_constants.dart';
import 'package:color_rash/presentation/widgets/game_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:color_rash/presentation/theme/app_colors.dart';

import 'package:color_rash/domain/initialization_notifier.dart';
import 'package:lottie/lottie.dart';

import 'game_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  // Flag to ensure initialization is only triggered once
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure initState completes before triggering the Future
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitializing) {
        _isInitializing = true;
        // Trigger the initialization process
        ref.read(initializationNotifierProvider.notifier).initialize().then((
          _,
        ) {
          // Once initialization is complete, we can navigate to the next screen
          // The build method will handle this when the state becomes 100%
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the progress state from the notifier
    final InitializationState initializationState = ref.watch(
      initializationNotifierProvider,
    );

    // If progress is 100%, we're done loading.
    if (initializationState.progress == 1.0) {
      return const GameScreen();
    }

    // Show the progress bar while loading
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Lottie.asset(
                AppFilePaths.lottieFile,
                width: double.infinity,
                height: MediaQuery.sizeOf(context).width * 0.7,
                repeat: true, // Make it loop indefinitely
              ),
              Column(
                children: [
                  GameProgressBar(
                    progress: initializationState.progress,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 35,
                    borderRadius: 20.0,
                    backgroundColor: AppColors.accentColor.withOpacity(0.3),
                    fillColor: AppColors.accentColor,
                    borderColor: AppColors.gameOverOverlayColor.withOpacity(
                      0.5,
                    ),
                    borderWidth: 2.0,
                  ),
                  SizedBox(height: 20),
                  Text(
                    initializationState.message, // <--- Use the dynamic message
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
