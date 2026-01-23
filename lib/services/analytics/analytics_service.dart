import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';

/// Analytics Service - Marketing Engine & Conversion Tracking
/// Tracks critical business events for Google Ads optimization and user attribution
/// 
/// Key Events:
/// - purchase_success: User completes premium purchase (with value & currency)
/// - analysis_started: User initiates bulletin analysis
/// - rewarded_ad_watched: User completes rewarded ad view
/// 
/// User Attribution:
/// - Sets user_type property to identify premium users ("whales") for ad targeting
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize Analytics Service
  static void initialize({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) {
    _analytics = analytics ?? FirebaseAnalytics.instance;
    _crashlytics = crashlytics;
    Logger.log('AnalyticsService initialized', tag: 'Analytics');
  }

  // ==================== CONVERSION TRACKING EVENTS ====================

  /// Track successful purchase - Critical for Google Ads conversion optimization
  /// 
  /// Parameters:
  /// - [productId]: Unique identifier for the subscription package (e.g., 'premium_monthly')
  /// - [value]: Purchase amount in decimal format (e.g., 19.99)
  /// - [currency]: ISO 4217 currency code (e.g., 'USD', 'EUR', 'GBP')
  /// - [transactionId]: Optional unique transaction identifier from payment provider
  /// 
  /// This event helps Google Ads:
  /// 1. Identify high-value users for lookalike audiences
  /// 2. Optimize ad delivery to users likely to convert
  /// 3. Calculate ROAS (Return on Ad Spend)
  static Future<void> logPurchaseSuccess({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  }) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        print('[Analytics] Purchase Success: $productId | $value $currency');
      }

      // Log to Firebase Analytics
      await _analytics?.logEvent(
        name: 'purchase_success',
        parameters: {
          'product_id': productId,
          'value': value,
          'currency': currency,
          'transaction_id': transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      // Also log using Firebase's standard purchase event for AdMob integration
      await _analytics?.logPurchase(
        currency: currency,
        value: value,
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: 'Premium Subscription',
            price: value,
            quantity: 1,
          ),
        ],
        transactionId: transactionId,
      );

      // Set user as premium for targeting
      await setUserTypePremium();

      Logger.log(
        'Purchase tracked: $productId ($value $currency)',
        tag: 'Analytics',
      );
    } catch (e, stackTrace) {
      // Log error to Crashlytics
      _crashlytics?.recordError(
        e,
        stackTrace,
        reason: 'Failed to log purchase_success event',
      );
      
      // Log purchase error for business intelligence
      await _logPurchaseError(
        productId: productId,
        value: value,
        currency: currency,
        errorMessage: e.toString(),
      );

      Logger.error(
        'Failed to track purchase: $productId',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Track analysis started - Measures engagement and user intent
  /// 
  /// Parameters:
  /// - [userId]: Current user ID
  /// - [creditsRemaining]: Number of credits user has after this analysis
  /// - [isPremium]: Whether user has premium subscription
  /// 
  /// This event helps identify:
  /// 1. Users who are actively engaged with the core feature
  /// 2. Free users approaching credit limit (potential upsell targets)
  /// 3. Usage patterns for retention optimization
  static Future<void> logAnalysisStarted({
    required String userId,
    required int creditsRemaining,
    required bool isPremium,
  }) async {
    try {
      if (kDebugMode) {
        print('[Analytics] Analysis Started: User $userId | Credits: $creditsRemaining');
      }

      await _analytics?.logEvent(
        name: 'analysis_started',
        parameters: {
          'user_id': userId,
          'credits_remaining': creditsRemaining,
          'is_premium': isPremium,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      Logger.log(
        'Analysis started tracked for user: $userId',
        tag: 'Analytics',
      );
    } catch (e, stackTrace) {
      _crashlytics?.recordError(
        e,
        stackTrace,
        reason: 'Failed to log analysis_started event',
      );

      Logger.error(
        'Failed to track analysis start',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Track rewarded ad completion - Measures monetization via ads
  /// 
  /// Parameters:
  /// - [userId]: Current user ID
  /// - [creditsEarned]: Number of credits awarded (default: 1)
  /// - [adNetwork]: Ad network identifier (e.g., 'admob')
  /// 
  /// This event:
  /// 1. Tracks ad revenue attribution
  /// 2. Identifies users who prefer ad-supported model
  /// 3. Measures ad inventory fill rate and completion
  static Future<void> logRewardedAdWatched({
    required String userId,
    int creditsEarned = 1,
    String adNetwork = 'admob',
  }) async {
    try {
      if (kDebugMode) {
        print('[Analytics] Rewarded Ad Watched: User $userId | Credits: $creditsEarned');
      }

      await _analytics?.logEvent(
        name: 'rewarded_ad_watched',
        parameters: {
          'user_id': userId,
          'credits_earned': creditsEarned,
          'ad_network': adNetwork,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      // Also use Firebase's standard ad impression event
      await _analytics?.logEvent(
        name: 'ad_impression',
        parameters: {
          'ad_type': 'rewarded',
          'ad_network': adNetwork,
        },
      );

      Logger.log(
        'Rewarded ad tracked for user: $userId',
        tag: 'Analytics',
      );
    } catch (e, stackTrace) {
      _crashlytics?.recordError(
        e,
        stackTrace,
        reason: 'Failed to log rewarded_ad_watched event',
      );

      Logger.error(
        'Failed to track rewarded ad',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  // ==================== USER ATTRIBUTION ====================

  /// Set user property as premium - Critical for Google Ads targeting
  /// 
  /// This property identifies "whale" users (high-value customers) for:
  /// 1. Lookalike audience creation in Google Ads
  /// 2. Exclusion from free user acquisition campaigns
  /// 3. Inclusion in retention/upsell campaigns
  static Future<void> setUserTypePremium() async {
    try {
      await _analytics?.setUserProperty(
        name: 'user_type',
        value: 'premium',
      );

      if (kDebugMode) {
        print('[Analytics] User property set: user_type = premium');
      }

      Logger.log('User type set to premium', tag: 'Analytics');
    } catch (e) {
      Logger.error(
        'Failed to set user_type property',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Set user property as free user
  static Future<void> setUserTypeFree() async {
    try {
      await _analytics?.setUserProperty(
        name: 'user_type',
        value: 'free',
      );

      if (kDebugMode) {
        print('[Analytics] User property set: user_type = free');
      }

      Logger.log('User type set to free', tag: 'Analytics');
    } catch (e) {
      Logger.error(
        'Failed to set user_type property',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Set user ID for cross-platform tracking
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics?.setUserId(id: userId);
      Logger.log('User ID set: $userId', tag: 'Analytics');
    } catch (e) {
      Logger.error('Failed to set user ID', error: e, tag: 'Analytics');
    }
  }

  // ==================== ERROR TRACKING ====================

  /// Log purchase error - Critical for identifying checkout issues
  /// 
  /// Tracks why purchases fail so you can:
  /// 1. Identify payment provider issues
  /// 2. Detect fraudulent transactions
  /// 3. Fix UX issues causing drop-off
  static Future<void> _logPurchaseError({
    required String productId,
    required double value,
    required String currency,
    required String errorMessage,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'purchase_error',
        parameters: {
          'product_id': productId,
          'value': value,
          'currency': currency,
          'error_message': errorMessage,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      if (kDebugMode) {
        print('[Analytics] Purchase Error: $productId | Error: $errorMessage');
      }
    } catch (e) {
      // Fail silently - don't cascade errors
      Logger.error(
        'Failed to log purchase error',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Log analysis error - Track analysis failures for quality monitoring
  static Future<void> logAnalysisError({
    required String userId,
    required String errorType,
    required String errorMessage,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'analysis_error',
        parameters: {
          'user_id': userId,
          'error_type': errorType,
          'error_message': errorMessage,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      if (kDebugMode) {
        print('[Analytics] Analysis Error: $errorType | $errorMessage');
      }

      Logger.log(
        'Analysis error tracked: $errorType',
        tag: 'Analytics',
      );
    } catch (e) {
      Logger.error(
        'Failed to log analysis error',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  // ==================== ADDITIONAL BUSINESS EVENTS ====================

  /// Track screen views for funnel analysis
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
      
      if (kDebugMode) {
        print('[Analytics] Screen View: $screenName');
      }
    } catch (e) {
      Logger.error('Failed to log screen view', error: e, tag: 'Analytics');
    }
  }

  /// Track onboarding completion
  static Future<void> logOnboardingCompleted(String userId) async {
    try {
      await _analytics?.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      Logger.log('Onboarding completed tracked', tag: 'Analytics');
    } catch (e) {
      Logger.error(
        'Failed to log onboarding completion',
        error: e,
        tag: 'Analytics',
      );
    }
  }

  /// Track free credit exhaustion - Prime upsell opportunity
  static Future<void> logCreditsExhausted(String userId) async {
    try {
      await _analytics?.logEvent(
        name: 'credits_exhausted',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (kDebugMode) {
        print('[Analytics] Credits Exhausted: User $userId - Prime Upsell Opportunity!');
      }

      Logger.log('Credits exhausted tracked', tag: 'Analytics');
    } catch (e) {
      Logger.error(
        'Failed to log credits exhausted',
        error: e,
        tag: 'Analytics',
      );
    }
  }
}
