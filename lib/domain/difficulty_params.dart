// lib/domain/difficulty_params.dart

/// A data class to hold the calculated difficulty parameters for a specific level.
class DifficultyParams {
  final double speed;
  final double interval;
  final int gradientIndex;
  final int level;

  const DifficultyParams({
    required this.speed,
    required this.interval,
    required this.gradientIndex,
    required this.level,
  });
}

// lib/domain/difficulty_update_result.dart

/// A data class to hold the result of a difficulty update.
class DifficultyUpdateResult {
  final double speed;
  final double interval;
  final int gradientIndex;
  final int level;
  final bool showLevelUpOverlay;

  const DifficultyUpdateResult({
    required this.speed,
    required this.interval,
    required this.gradientIndex,
    required this.level,
    required this.showLevelUpOverlay,
  });
}
