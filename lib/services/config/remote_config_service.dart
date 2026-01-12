// Firebase Remote Config for secure API key management
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isInitialized = false;

  /// Initializes Remote Config with defaults
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set default values (fallback)
      await _remoteConfig.setDefaults({
        'gemini_api_key': '',
        'enable_premium_features': false,
        'max_free_questions': 3,
        'enable_analytics': true,
        'google_cloud_api_key': '',
        'tts_voice_name': 'en-US-Wavenet-D',
      });

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      _isInitialized = true;
    } catch (e) {
      throw RemoteConfigException('Failed to initialize Remote Config: $e');
    }
  }

  /// Gets Gemini API key from Remote Config
  /// Falls back to local constant if not available
  String getGeminiApiKey(String fallbackKey) {
    if (!_isInitialized) {
      return fallbackKey;
    }
    
    final remoteKey = _remoteConfig.getString('gemini_api_key');
    return remoteKey.isEmpty ? fallbackKey : remoteKey;
  }

  /// Gets max free questions limit
  int getMaxFreeQuestions() {
    return _remoteConfig.getInt('max_free_questions');
  }

  /// Checks if premium features are enabled
  bool arePremiumFeaturesEnabled() {
    return _remoteConfig.getBool('enable_premium_features');
  }

  /// Refreshes config values
  Future<void> refresh() async {
    await _remoteConfig.fetchAndActivate();
  }

  /// Gets Google Cloud TTS API key from Remote Config
  /// Falls back to local constant if not available
  String getGoogleCloudTtsApiKey(String fallbackKey) {
    if (!_isInitialized) {
      return fallbackKey;
    }
    
    final remoteKey = _remoteConfig.getString('google_cloud_api_key');
    return remoteKey.isEmpty ? fallbackKey : remoteKey;
  }

  /// Gets TTS voice name from Remote Config
  /// Defaults to en-US-Wavenet-D if not configured
  String getTtsVoiceName() {
    if (!_isInitialized) {
      return 'en-US-Wavenet-D';
    }
    
    final voiceName = _remoteConfig.getString('tts_voice_name');
    return voiceName.isEmpty ? 'en-US-Wavenet-D' : voiceName;
  }
}

class RemoteConfigException implements Exception {
  final String message;
  RemoteConfigException(this.message);
  
  @override
  String toString() => message;
}
