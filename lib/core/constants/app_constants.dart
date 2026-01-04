// Application-wide constant values
class AppConstants {
  static const String appName = 'SolveLens';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY'; // Should be loaded from .env
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_KEY';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String subscriptionsCollection = 'subscriptions';
  
  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String subscriptionTypeKey = 'subscription_type';
}
