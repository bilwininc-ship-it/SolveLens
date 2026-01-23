import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../firebase/firebase_service.dart';
import '../../core/utils/logger.dart';

/// Remote Config Service - Centralized Remote Configuration Management
/// Manages app-wide settings, maintenance mode, version control, and announcements
class RemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;

  /// Initialize Remote Config with default values
  static Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseService.remoteConfig;

      if (_remoteConfig == null) {
        Logger.error(
          'Remote Config is null. Ensure Firebase is initialized first.',
          tag: 'RemoteConfig',
        );
        return;
      }

      // Set default values
      await _remoteConfig!.setDefaults({
        'is_maintenance': false,
        'min_version': '1.0.0',
        'app_version': '1.0.0',
        'dashboard_announcement': '',
        'announcement_enabled': false,
        'daily_free_credits': 3,
        'ad_reward_credits': 1,
        'premium_daily_limit': 15,
        'support_email': 'bilwininc@gmail.com',
      });

      // Fetch and activate latest config
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig!.fetchAndActivate();

      Logger.log('Remote Config initialized successfully', tag: 'RemoteConfig');
    } catch (e) {
      Logger.error(
        'Remote Config initialization failed',
        error: e,
        tag: 'RemoteConfig',
      );
    }
  }

  // ==================== MAINTENANCE & VERSION CONTROL ====================

  /// Check if app is in maintenance mode
  static bool get isMaintenanceMode {
    try {
      return _remoteConfig?.getBool('is_maintenance') ?? false;
    } catch (e) {
      Logger.error('Failed to get maintenance mode', error: e, tag: 'RemoteConfig');
      return false;
    }
  }

  /// Get minimum required app version
  static String get minimumVersion {
    try {
      return _remoteConfig?.getString('min_version') ?? '1.0.0';
    } catch (e) {
      Logger.error('Failed to get minimum version', error: e, tag: 'RemoteConfig');
      return '1.0.0';
    }
  }

  /// Get current app version from Remote Config
  static String get appVersion {
    try {
      return _remoteConfig?.getString('app_version') ?? '1.0.0';
    } catch (e) {
      Logger.error('Failed to get app version', error: e, tag: 'RemoteConfig');
      return '1.0.0';
    }
  }

  /// Check if update is required
  /// Compares current app version with minimum required version
  static bool isUpdateRequired(String currentVersion) {
    try {
      final minVersion = minimumVersion;
      return _compareVersions(currentVersion, minVersion) < 0;
    } catch (e) {
      Logger.error('Failed to check update requirement', error: e, tag: 'RemoteConfig');
      return false;
    }
  }

  /// Compare two version strings (e.g., "1.2.3" vs "1.3.0")
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final part1 = i < v1Parts.length ? v1Parts[i] : 0;
      final part2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }

    return 0;
  }

  // ==================== ANNOUNCEMENTS ====================

  /// Get dashboard announcement message
  static String get dashboardAnnouncement {
    try {
      return _remoteConfig?.getString('dashboard_announcement') ?? '';
    } catch (e) {
      Logger.error('Failed to get announcement', error: e, tag: 'RemoteConfig');
      return '';
    }
  }

  /// Check if announcements are enabled
  static bool get isAnnouncementEnabled {
    try {
      return _remoteConfig?.getBool('announcement_enabled') ?? false;
    } catch (e) {
      Logger.error('Failed to check announcement status', error: e, tag: 'RemoteConfig');
      return false;
    }
  }

  /// Check if announcement should be shown
  static bool get shouldShowAnnouncement {
    return isAnnouncementEnabled && dashboardAnnouncement.isNotEmpty;
  }

  // ==================== CREDIT CONFIGURATION ====================

  /// Get daily free credits amount
  static int get dailyFreeCredits {
    try {
      return _remoteConfig?.getInt('daily_free_credits') ?? 3;
    } catch (e) {
      Logger.error('Failed to get daily free credits', error: e, tag: 'RemoteConfig');
      return 3;
    }
  }

  /// Get ad reward credits amount
  static int get adRewardCredits {
    try {
      return _remoteConfig?.getInt('ad_reward_credits') ?? 1;
    } catch (e) {
      Logger.error('Failed to get ad reward credits', error: e, tag: 'RemoteConfig');
      return 1;
    }
  }

  /// Get premium daily analysis limit
  static int get premiumDailyLimit {
    try {
      return _remoteConfig?.getInt('premium_daily_limit') ?? 15;
    } catch (e) {
      Logger.error('Failed to get premium limit', error: e, tag: 'RemoteConfig');
      return 15;
    }
  }

  // ==================== SUPPORT ====================

  /// Get support email
  static String get supportEmail {
    try {
      return _remoteConfig?.getString('support_email') ?? 'bilwininc@gmail.com';
    } catch (e) {
      Logger.error('Failed to get support email', error: e, tag: 'RemoteConfig');
      return 'bilwininc@gmail.com';
    }
  }

  // ==================== UTILITY ====================

  /// Manually fetch latest config (useful for testing)
  static Future<void> fetchConfig() async {
    try {
      await _remoteConfig?.fetchAndActivate();
      Logger.log('Remote Config fetched successfully', tag: 'RemoteConfig');
    } catch (e) {
      Logger.error('Failed to fetch Remote Config', error: e, tag: 'RemoteConfig');
    }
  }

  /// Get all config values for debugging
  static Map<String, dynamic> getAllConfigs() {
    if (kDebugMode) {
      return {
        'is_maintenance': isMaintenanceMode,
        'min_version': minimumVersion,
        'app_version': appVersion,
        'dashboard_announcement': dashboardAnnouncement,
        'announcement_enabled': isAnnouncementEnabled,
        'daily_free_credits': dailyFreeCredits,
        'ad_reward_credits': adRewardCredits,
        'premium_daily_limit': premiumDailyLimit,
        'support_email': supportEmail,
      };
    }
    return {};
  }
}
