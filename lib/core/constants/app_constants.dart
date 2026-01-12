// Application-wide constant values
class AppConstants {
  static const String appName = 'SolveLens';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY'; // Should be loaded from .env
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_KEY';
  
  // Google Cloud Text-to-Speech API
  // Get your API key from: https://console.cloud.google.com/apis/credentials
  // Make sure to enable "Cloud Text-to-Speech API" in your project
  static const String googleCloudTtsApiKey = 'YOUR_GOOGLE_CLOUD_TTS_API_KEY';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String subscriptionsCollection = 'subscriptions';
  
  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String subscriptionTypeKey = 'subscription_type';
}
