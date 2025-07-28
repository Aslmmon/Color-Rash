import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // <--- NEW
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // <--- Existing
import 'package:firebase_performance/firebase_performance.dart'; // <--- NEW

import 'package:color_rash/core/app_monitoring_service.dart';

/// Concrete implementation of IAppMonitoringService using Firebase services.
class FirebaseMonitoringService implements IAppMonitoringService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // Map to store active HttpMetric/Trace instances for performance monitoring
  final Map<String, Trace> _activeTraces = {};

  @override
  Future<void> initialize() async {
    // Firebase is initialized earlier in main.dart via Firebase.initializeApp().
    // This method can be used for any post-Firebase.initializeApp setup specific to these services.
    // For example, setting up non-fatal error handling for Dart errors (outside Flutter framework errors).
    FlutterError.onError =
        recordFlutterFatalError; // Register global Flutter error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      // For Dart errors outside Flutter framework
      _crashlytics.recordError(error, stack, fatal: false);
      return true; // Return true to indicate error was handled
    };
  }

  // --- Analytics Implementation ---
  @override
  void logEvent(String name, {Map<String, Object>? parameters}) {
    _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  void setUserProperty(String name, String? value) {
    _analytics.setUserProperty(name: name, value: value);
  }

  // --- Crashlytics Implementation ---
  @override
  void logError(dynamic exception, StackTrace stack, {String? reason}) {
    _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: false, // Log as non-fatal
    );
  }

  @override
  void recordFlutterFatalError(FlutterErrorDetails errorDetails) {
    _crashlytics.recordFlutterFatalError(errorDetails);
  }

  // --- Performance Monitoring Implementation ---
  @override
  Future<void> startTrace(String name) async {
    if (_activeTraces.containsKey(name)) {
      // Trace already started, or not properly stopped. Log a warning.
      _crashlytics.log('Warning: Trace "$name" started while already active.');
      return;
    }
    final trace = _performance.newTrace(name);
    _activeTraces[name] = trace;
    await trace.start();
  }

  @override
  void stopTrace(String name) {
    final trace = _activeTraces.remove(name);
    if (trace != null) {
      trace.stop();
    } else {
      // Trace not found or already stopped. Log a warning.
      _crashlytics.log('Warning: Trace "$name" stopped but was not active.');
    }
  }

  @override
  void incrementTraceMetric(String traceName, String metricName, int value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.incrementMetric(metricName, value);
    } else {
      _crashlytics.log(
        'Warning: Metric incremented for inactive trace "$traceName".',
      );
    }
  }
}
