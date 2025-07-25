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
    18.0; // Specific font size for "Resume" button

// Game Over Overlay specific constants
const double kGameOverOverlayOpacity =
    0.5; // Opacity of the game over overlay (0.0 to 1.0)
const double kRestartButtonWidth = 200.0; // <--- HERE IT IS
const double kRestartButtonHeight = 60.0;
const double kRestartButtonTextSize =
    14.0; // Specific font size for "Start/Play Again" button

// lib/domain/game_constants.dart

// ... (your existing constants)

// General Padding/Spacing constants (ensure these are present)
const double kSmallSpacing = 10.0; // <--- NEW: For the SizedBox height 10.0

const double kGameOverScoreSpacing =
    20.0; // Spacing between "Game Over" and "Your Score"
const double kGameOverHighscoreSpacing =
    30.0; // Spacing between "High Score" and button

const double kPauseOverlaySpacing =
    40.0; // <--- NEW: Spacing between "Paused" text and "Resume" button


const int kMaxLevel = 15; // Or whatever number of levels you want for an ending
