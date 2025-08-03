// lib/domain/game_constants.dart

// --- Game Difficulty & Mechanics Constants ---
// Score thresholds for increasing difficulty
// lib/domain/game_constants.dart

// This class centralizes all game-related constants.
// All constants are static const, making them accessible via AppConstants.CONSTANT_NAME.
class AppConstants {
  // --- Game Difficulty & Mechanics Constants ---
  static const int kScoreThresholdForSpeedIncrease = 5;
  static const double kSpeedIncrementFactor =
      0.1; // e.g., 10% increase per threshold
  static const int kScoreThresholdForIntervalDecrease = 10;
  static const int kScoreThresholdForGradientChange = 25;
  static const double kIntervalDecrementAmount =
      0.1; // e.g., decrease by 0.1 seconds
  static const double kMinSpawnInterval = 0.5; // Minimum spawn interval allowed
  static const double kObjectSpawnPeriodInitial =
      2.0; // Initial spawn period for objects
  static const double kObjectSpeedInitial =
      1; // Initial spawn period for objects
  static const int kGameScoreInitial = 0; // Initial spawn period for objects
  static const int kGameGradientIndexInitial =
      0; // Initial spawn period for objects
  static const int kGameLevelInitial = 1; // Initial spawn period for objects
  static const int kGameScoreToBeIncreaseFromCorrectTap =
      1; // Initial spawn period for objects
  static const int kGameLevelsBoostedValueAfterReward =
      2; // Initial spawn period for objects

  // --- UI/Animation Constants ---
  static const int kLevelUpOverlayDisplayDurationMs =
      1500; // Duration for level up overlay to show in milliseconds (1.5 seconds)
  static const int kBackgroundGradientChangeDurationMs =
      1; // Duration for background gradient color change (1 second)

  // Game Over Overlay specific constants
  static const double kGameOverOverlayOpacity =
      0.7; // Opacity of the game over overlay (0.0 to 1.0)
  static const double kGameOverScoreSpacing =
      20.0; // Spacing between "Game Over" and "Your Score"
  static const double kGameOverHighscoreSpacing =
      30.0; // Spacing between "High Score" and button

  // Pause Overlay specific constants
  static const double kPauseOverlayOpacity =
      0.7; // Opacity of the pause screen overlay (0.0 to 1.0)
  static const double kPauseOverlaySpacing =
      40.0; // Spacing between "Paused" text and "Resume" button

  // General Padding/Spacing constants
  static const double kDefaultPadding = 16.0;
  static const double kLargePadding = 32.0;
  static const double kSmallSpacing = 10.0; // For small SizedBox heights

  // --- Flame Game Component Constants ---
  static const double kObjectBaseSpeed =
      150; // Pixels per second for falling objects
  static const double kObjectRadius = 30.0; // Radius of falling circles
  static const double kCatchZoneHeight =
      200; // Height of the catch zone from the bottom
  static const double kCatchZoneLineWidth =
      2.5; // Thickness of the catch zone line
  static const double kReceiverHeight =
      100.0; // Height of the receiver buttons at the bottom

  // Catch zone line pulsing (moved from ColorRushGame for centralization)
  static const double kLinePulseRange =
      50.0; // Distance from line to trigger pulse
  static const double kLinePulseDuration = 0.3; // How fast the pulse happens

  // Particle Effect Constants (from ColorRushGame)
  static const int kParticleCount = 35;
  static const double kParticleLifespan = 0.5;
  static const double kParticleSpeed =
      100; // Base speed for random particle velocity
  static const double kParticleAccelerationY =
      200; // Gravity-like acceleration for particles
  static const double kParticleRadius = 3;

  // --- Ad Integration Constants ---
  static const int kAdShowFrequency =
      1; // Show interstitial ad every X game overs
  // Test Ad Unit IDs (These would be replaced by production IDs in prod builds via CI/CD secrets)
  static const String kInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String kInterstitialAdUnitIdiOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String kBannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String kBannerAdUnitIdiOS =
      'ca-app-pub-3940256099942544/2934735716';
  static const String kRewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String kRewardedAdUnitIdiOS =
      'ca-app-pub-3940256099942544/1712485301';

  // --- Button Styling Constants ---
  static const int kButtonPressAnimationDurationMs = 150;
  static const double kButtonPressScaleFactor = 0.9;
  static const double kColorButtonBorderWidth =
      3.0; // Border for color input buttons
  static const double kButtonBottomPadding =
      64.0; // Original padding for color input buttons
  static const double kBannerAdHeight =
      50.0; // Standard AdSize.banner height (used in padding calc)

  // Game Button (AnimatedButton wrapper) specific constants
  static const double kControlButtonSize = 60.0; // Size for Pause/Mute buttons
  static const double kControlBtnBorderRadius = 30.0; // Circular buttons
  static const double kControlButtonIconSize =
      30.0; // Icon size for control buttons

  static const double kPauseButtonWidth = 200.0;
  static const double kPauseButtonHeight = 60.0;
  static const double kPauseButtonTextSize =
      24.0; // Font size for "Resume" button

  static const double kRestartButtonWidth = 200.0;
  static const double kRestartButtonHeight = 60.0;
  static const double kRestartButtonTextSize =
      24.0; // Font size for "Start/Play Again" button

  static const double kMainMenuButtonWidth = 200.0;
  static const double kMainMenuButtonHeight = 60.0;
  static const double kMainMenuButtonTextSize =
      18.0; // Font size for "Main Menu" button

  // --- Game Progression Limits ---
  static const int kMaxLevel = 15; // Max level to reach for a 'win'

  // --- Audio Pool Specifics ---
  static const int minPlayersInAudioPool = 1; // Min players for SFX AudioPools
  static const int maxPlayersInAudioPool = 3; // Max players for SFX AudioPools

  // --- Font Size Adjustments for Web/Mobile (Used in AppTheme & Overlays) ---
  static const double kTextFontSizeInMobile =
      24.0; // Default for smaller body text on mobile
  static const double kTextFontSizeInWeb =
      18.0; // Default for smaller body text on web

  static const double kHeadlineLargeFontSizeMobile =
      48.0; // Base for mobile headlines
  static const double kHeadlineLargeFontSizeWeb =
      60.0; // Larger for web headlines

  static const double kWinTitleFontSizeMobile =
      70.0; // Specific huge size for "YOU WIN!" on mobile
  static const double kWinTitleFontSizeWeb =
      90.0; // Specific huge size for "YOU WIN!" on web
}

// ... (other constants)
class AppFilePaths {
  static const String logo = 'assets/images/logo.png';
  static const String background = 'assets/images/background.png';
  static const String pauseIcon = 'assets/icons/pause.png';
  static const String muteIcon = 'assets/icons/mute.png';
  static const String unmuteIcon = 'assets/icons/unmute.png';
  static const String playIcon = 'assets/icons/play.png';
  static const String restartIcon = 'assets/icons/restart.png';
  static const String devEnvironment = '.env.dev';
  static const String prodEnvironment = '.env.prod';
}

class AppMonitoringLogs {
  static const String gameStartedLog = 'game_started';
  static const String gameSessionDuration = 'game_session_duration';
  static const String levelUpLog = 'level_up';
  static const String gameEndedLog = 'game_ended';
  static const String rewardedAdLevelBoostGranted =
      'rewarded_ad_level_boost_granted';
}

class AppAudioPaths {
  static const String bgm = 'bg_music.ogg';
  static const String correctTap = 'correct_tap.ogg';
  static const String errorTap = 'error_tap.ogg';
  static const String celebrate = 'celebrate.mp3';
  static const String gameOver = 'game_over.ogg';
}
// lib/domain/app_strings.dart

class AppStrings {
  static const String appTitle = 'Color Rash';
  static const String startLevelHint = 'You will begin at Level';
  static const String tutorialWelcomeTitle = 'WELCOME  TO COLOR RASH!';
  static const String tutorialWelcomeBody =
      'Tap the screen quickly to match falling colors and conquer the levels!';

  static const String tutorialMatchColorTitle = 'MATCH THE COLOR!';
  static const String tutorialMatchColorBody =
      'Tap the Colored Circles buttons  at the bottom that precisely matches the color of the falling circle.';

  static const String tutorialTimingKeyTitle = 'TIMING IS KEY!';
  static const String tutorialTimingKeyBody =
      'Only tap when the falling circle reaches below the glowing line at the bottom. Too early or too late is a miss!';

  static const String tutorialSurviveScoreTitle = 'SURVIVE & SCORE!';
  static const String tutorialSurviveScoreBody =
      'Score points for every correct tap! Miss a color, or let a circle pass, it will be Game Over!';

  static const String tutorialGetReadyTitle = 'GET READY FOR A RASH!';
  static const String tutorialGetReadyBody =
      'The game gets faster and the colors change as you score more points. Reach Level {level} to win!'; // Placeholder for level

  static const String tutorialButtonBack = 'Back';
  static const String tutorialButtonNext = 'Next';
  static const String tutorialButtonGotItLetSPlay = 'Got It! Let\'s Play!';

  // --- Game Over Overlay Strings ---
  static const String gameOverTitle = 'Game Over';
  static const String youWinTitle = 'YOU WIN!';
  static const String yourScoreLabel = 'Your Score:';
  static const String highScoreLabel = 'High Score:';
  static const String startGameButton = 'Start Game';
  static const String playAgainButton = 'Play Again';
  static const String pausedTitle = 'Paused';
  static const String resumeButton = 'Resume';

  // --- Other UI Strings ---
  static const String scoreLabel = 'Score:';
  static const String showTutorialButton = 'Show Tutorial';

  static const String adErrorLoadingBanner = 'Error loading banner ad:';
  static const String interstitialAdsNotSupportedWeb =
      'Interstitial ads not supported on web platform.';
  static const String bannerAdsNotSupportedWeb =
      'Banner ads not supported on web platform.';

  static const String watchAdForBoost = 'Watch Ad for';
  static const String levelBoostAmount = '+2 Levels!'; // Or '+2 Levels'
  static const String mainMenuButton =
      'Main Menu'; // Make sure this is here if used in GameOverOverlay
}
