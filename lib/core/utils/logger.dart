import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Enhanced Logger with Firebase Analytics Integration
/// Logs events to console in debug mode and sends to Firebase Analytics
class Logger {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize logger with Firebase services
  static void initialize({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) {
    _analytics = analytics;
    _crashlytics = crashlytics;
  }

  /// Log general message
  static void log(String message, {String tag = 'SolveLens'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  /// Log error with optional error object
  static void error(
    String message, {
    String tag = 'SolveLens',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      print('[$tag] ERROR: $message');
      if (error != null) print('Details: $error');
    }

    // Send to Crashlytics
    if (error != null) {
      _crashlytics?.recordError(error, stackTrace, reason: message);
    }
  }

  // ==================== FIREBASE ANALYTICS EVENTS ====================

  /// Log user login event
  static Future<void> logLogin(String method) async {
    log('User logged in via: $method');
    await _analytics?.logLogin(loginMethod: method);
  }

  /// Log user signup event
  static Future<void> logSignup(String method) async {
    log('User signed up via: $method');
    await _analytics?.logSignUp(signUpMethod: method);
  }

  /// Log image upload event
  static Future<void> logImageUpload() async {
    log('Image uploaded for analysis');
    await _analytics?.logEvent(
      name: 'image_upload',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log analysis started event
  static Future<void> logAnalysisStarted() async {
    log('Analysis started');
    await _analytics?.logEvent(
      name: 'analysis_started',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log analysis completed event
  static Future<void> logAnalysisCompleted({
    required int matchCount,
    required double confidenceScore,
  }) async {
    log('Analysis completed: $matchCount matches, confidence: $confidenceScore');
    await _analytics?.logEvent(
      name: 'analysis_completed',
      parameters: {
        'match_count': matchCount,
        'confidence_score': confidenceScore,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log credits used event
  static Future<void> logCreditsUsed(int creditsRemaining) async {
    log('Credits used. Remaining: $creditsRemaining');
    await _analytics?.logEvent(
      name: 'credits_used',
      parameters: {
        'credits_remaining': creditsRemaining,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad watched event
  static Future<void> logAdWatched() async {
    log('Rewarded ad watched');
    await _analytics?.logEvent(
      name: 'ad_watched',
      parameters: {
        'ad_type': 'rewarded',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log premium purchase event
  static Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    log('Premium purchased: $productId');
    await _analytics?.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Premium Subscription',
          price: price,
        ),
      ],
    );
  }

  /// Log screen view event
  static Future<void> logScreenView(String screenName) async {
    log('Screen viewed: $screenName');
    await _analytics?.logScreenView(
      screenName: screenName,
    );
  }

  /// Log custom event
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    log('Custom event: $eventName');
    await _analytics?.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  /// Set user ID for analytics
  static Future<void> setUserId(String userId) async {
    await _analytics?.setUserId(id: userId);
  }

  /// Set user property
  static Future<void> setUserProperty(
    String name,
    String value,
  ) async {
    await _analytics?.setUserProperty(name: name, value: value);
  }
}
