/// SolveLens App Constants
/// Contains API keys and configuration values
class AppConstants {
  // Gemini AI API Key
  // TODO: Add your Gemini API key here
  // Get it from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // App Configuration
  static const String appName = 'SolveLens';
  static const String appVersion = '1.0.0';
  
  // Analysis Configuration
  static const int defaultCredits = 3;
  static const int creditCostPerAnalysis = 1;
  
  // Remote Config Keys (for future use)
  static const String rcMaintenanceMode = 'is_maintenance';
  static const String rcMinVersion = 'min_version';
  static const String rcAnnouncementText = 'announcement_text';
}