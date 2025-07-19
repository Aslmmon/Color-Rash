// lib/domain/game_constants.dart

// --- Game Difficulty & Mechanics Constants ---
// Score thresholds for increasing difficulty
const int kScoreThresholdForSpeedIncrease = 5;
const double kSpeedIncrementFactor = 0.1; // e.g., 10% increase per threshold

const int kScoreThresholdForIntervalDecrease = 10;
const double kIntervalDecrementAmount = 0.1; // e.g., decrease by 0.1 seconds
const double kMinSpawnInterval = 0.5; // Minimum spawn interval allowed

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
const int kAdShowFrequency = 3; // Show interstitial ad every X game overs

// Add common padding/spacing constants if needed across UI files
const double kDefaultPadding = 16.0;
const double kLargePadding = 32.0;
const double kButtonBottomPadding = 64.0; // Original padding for buttons
const double kBannerAdHeight = 50.0; // Standard AdSize.banner height
const kObjectSpawnPeriodInitial = 2.0;
// You can use a prefix like 'k' for constants (Kotlin convention) or 'App'
// or no prefix at all, just ensure consistency. 'k' is quite common in Flutter for global constants.
