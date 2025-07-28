// lib/domain/game_constants.dart

// --- Game Difficulty & Mechanics Constants ---
// Score thresholds for increasing difficulty
const int kScoreThresholdForSpeedIncrease = 5;
const double kSpeedIncrementFactor = 0.1; // e.g., 10% increase per threshold
const int kScoreThresholdForIntervalDecrease = 10;
const int kScoreThresholdForGradientChange = 25;
const double kIntervalDecrementAmount = 0.1; // e.g., decrease by 0.1 seconds
const double kMinSpawnInterval = 0.5; // Minimum spawn interval allowed
// --- UI/Animation Constants ---

const int kLevelUpOverlayDisplayDurationMs =
    1500; // Duration for level up overlay to show in milliseconds (1.5 seconds)

// Flame Game Component Constants
const double kObjectBaseSpeed = 150; // Pixels per second for falling objects
const double kObjectRadius = 30.0; // Radius of falling circles
const double kCatchZoneHeight = 200; // Height of the catch zone from the bottom
const double kCatchZoneLineWidth = 2.5; // Thickness of the catch zone line
const double kReceiverHeight =
    100.0; // Height of the receiver buttons at the bottom

// Particle Effect Constants (from ColorRushGame)
const int kParticleCount = 35;
const double kParticleLifespan = 0.5;
const double kParticleSpeed = 100; // Base speed for random particle velocity
const double kParticleAccelerationY =
    200; // Gravity-like acceleration for particles
const double kParticleRadius = 3;

// --- Ad Integration Constants ---
const int kAdShowFrequency = 1; // Show interstitial ad every X game overs

// Add these Ad Unit IDs
const String kInterstitialAdUnitIdAndroid =
    'ca-app-pub-3940256099942544/1033173712'; // Test ID
const String kInterstitialAdUnitIdiOS =
    'ca-app-pub-3940256099942544/4411468910'; // Test ID
const String kBannerAdUnitIdAndroid =
    'ca-app-pub-3940256099942544/6300978111'; // Test ID
const String kBannerAdUnitIdiOS =
    'ca-app-pub-3940256099942544/2934735716'; // Test ID

const int kButtonPressAnimationDurationMs = 150;
const double kButtonPressScaleFactor = 0.9;
const double kColorButtonBorderWidth = 3.0; //
// Add common padding/spacing constants if needed across UI files
const double kDefaultPadding = 16.0;
const double kLargePadding = 32.0;
const double kButtonBottomPadding = 64.0; // Original padding for buttons
const double kBannerAdHeight = 50.0; // Standard AdSize.banner height
const kObjectSpawnPeriodInitial = 2.0;
// You can use a prefix like 'k' for constants (Kotlin convention) or 'App'
// or no prefix at all, just ensure consistency. 'k' is quite common in Flutter for global constants.

// lib/domain/game_constants.dart

// ... (your existing constants)

// --- UI/Animation Constants ---
const int kBackgroundGradientChangeDurationMs =
    1; // Duration for background gradient color change (1 second)

const double kTextFontSizeInMobile = 25;
const double kTextFontSizeInMobileOverlay = 32;

const double kTextFontSizeInWeb = 25;

// Control Button (Pause/Mute) specific constants
const double kControlButtonSize = 60.0;
const double kControlBtnBorderRadius = 30.0; // For circular buttons
const double kControlButtonIconSize = 30.0;

// Pause Overlay specific constants
const double kPauseOverlayOpacity =
    0.7; // Opacity of the pause screen overlay (0.0 to 1.0)
const double kPauseButtonWidth = 200.0;
const double kPauseButtonHeight = 60.0;
const double kPauseButtonTextSize =
    24.0; // Specific font size for "Resume" button

// Game Over Overlay specific constants
const double kGameOverOverlayOpacity =
    0.7; // Opacity of the game over overlay (0.0 to 1.0)
const double kRestartButtonWidth = 200.0; // <--- HERE IT IS
const double kRestartButtonHeight = 60.0;
const double kRestartButtonTextSize =
    24.0; // Specific font size for "Start/Play Again" button

const double kSmallSpacing = 10.0; // <--- NEW: For the SizedBox height 10.0

const double kGameOverScoreSpacing =
    20.0; // Spacing between "Game Over" and "Your Score"
const double kGameOverHighscoreSpacing =
    30.0; // Spacing between "High Score" and button

const double kPauseOverlaySpacing =
    40.0; // <--- NEW: Spacing between "Paused" text and "Resume" button

const int kMaxLevel = 15; // Or whatever number of levels you want for an ending
const int minPlayersInAudioPool = 1;
const int maxPlayersInAudioPool = 3;
// lib/domain/game_constants.dart
// ... (your existing constants)

const double kHeadlineLargeFontSizeMobile = 48.0; // Example base for mobile
const double kHeadlineLargeFontSizeWeb = 60.0;   // Example larger for web

const double kWinTitleFontSizeMobile = 70.0; // Specific huge size for "YOU WIN!" on mobile
const double kWinTitleFontSizeWeb = 90.0;     // Specific huge size for "YOU WIN!" on web

// ... (other constants)
class AppFilePaths {
  static const String logo = 'assets/images/logo.png';
  static const String background = 'assets/images/background.png';
  static const String pauseIcon = 'assets/icons/pause.png';
  static const String muteIcon = 'assets/icons/mute.png';
  static const String unmuteIcon = 'assets/icons/unmute.png';
  static const String playIcon = 'assets/icons/play.png';
  static const String restartIcon = 'assets/icons/restart.png';
}

class AppAudioPaths {
  static const String bgm = 'bg_music.ogg';
  static const String correctTap = 'correct_tap.ogg';
  static const String errorTap = 'error_tap.ogg';
  static const String celebrate = 'celebrate.ogg';
  static const String gameOver = 'game_over.ogg';
}
// lib/domain/app_strings.dart

class AppStrings {
  // --- Game Names/Titles ---
  static const String appTitle = 'Color Rash';

  // --- Tutorial Overlay Strings ---
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

  // --- Ad/Monitoring Strings (if you want to abstract these too) ---
  // static const String adErrorLoadingBanner = 'Error loading banner ad:';
  // static const String interstitialAdsNotSupportedWeb = 'Interstitial ads not supported on web platform.';
  // static const String bannerAdsNotSupportedWeb = 'Banner ads not supported on web platform.';
}
