// lib/core/app_monitoring_service.dart
import 'package:flutter/foundation.dart'; // For FlutterErrorDetails, StackTrace

/// Interface for application monitoring and analytics services.
abstract class IAppMonitoringService {
  // --- Analytics ---
  /// Logs a custom analytical event.
  void logEvent(String name, {Map<String, dynamic>? parameters});

  /// Sets a user property for analytics (e.g., player_type, difficulty_preference).
  void setUserProperty(String name, String? value);

  // --- Crashlytics ---
  /// Logs a non-fatal error or a message to Crashlytics.
  void logError(dynamic exception, StackTrace stack, {String? reason});

  /// Records a fatal Flutter error to Crashlytics.
  void recordFlutterFatalError(FlutterErrorDetails errorDetails);

  // --- Performance Monitoring ---
  /// Starts a custom performance trace.
  Future<void> startTrace(String name);

  /// Stops a custom performance trace.
  void stopTrace(String name);

  /// Increments a counter for a given metric within a trace.
  void incrementTraceMetric(String traceName, String metricName, int value);

  // --- Initialization (to be called once at app startup) ---
  Future<void> initialize(); // To ensure native SDKs are ready
}
