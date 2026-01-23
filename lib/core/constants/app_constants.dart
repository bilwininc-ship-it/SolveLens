/// SolveLens App Constants
/// Contains API keys and configuration values
class AppConstants {
  // Gemini AI API Key
  // TODO: Add your Gemini API key here
  // Get it from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Football API (RapidAPI) Configuration
  // TODO: Add your RapidAPI key for api-football
  // Get it from: https://rapidapi.com/api-sports/api/api-football
  static const String footballApiKey = 'YOUR_RAPIDAPI_KEY_HERE';
  static const String footballApiBaseUrl = 'https://v3.football.api-sports.io';
  
  // App Configuration
  static const String appName = 'SolveLens';
  static const String appVersion = '1.0.0';
  
  // Analysis Configuration
  static const int defaultCredits = 3;
  static const int creditCostPerAnalysis = 1;
  static const int creditCostPerPrediction = 1;
  
  // Remote Config Keys (for future use)
  static const String rcMaintenanceMode = 'is_maintenance';
  static const String rcMinVersion = 'min_version';
  static const String rcAnnouncementText = 'announcement_text';
}
