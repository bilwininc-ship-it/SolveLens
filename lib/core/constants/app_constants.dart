// Application-wide constant values
// ⚠️ SECURITY NOTE: API keys are stored in Firebase Remote Config for security
// Never hardcode API keys in the codebase
class AppConstants {
  static const String appName = 'SolveLens';
  static const String appVersion = '1.0.0';
  
  // API Keys are managed through Firebase Remote Config
  // See: lib/services/config/remote_config_service.dart
  // - gemini_api_key: Gemini AI API key
  // - google_cloud_api_key: Google Cloud TTS API key
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String subscriptionsCollection = 'subscriptions';
  static const String notesCollection = 'notes';
  static const String historyCollection = 'history';
  
  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String subscriptionTypeKey = 'subscription_type';
  static const String firstLaunchKey = 'first_launch';
  static const String selectedLanguageKey = 'selected_language';
  
  // App Store / Play Store IDs (for IAP)
  static const String androidAppId = 'com.solvelens.app';
  static const String iosAppId = 'com.solvelens.app';
}
