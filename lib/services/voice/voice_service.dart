// Voice Service for Speech-to-Text and Google Cloud Text-to-Speech
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';
import '../config/remote_config_service.dart';

class VoiceService {
  final RemoteConfigService _remoteConfigService;
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isFetchingAudio = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isFetchingAudio => _isFetchingAudio;
  bool get isInitialized => _isInitialized;

  // Google Cloud TTS configuration - fetched from Remote Config
  static const String _ttsEndpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  static const String _languageCode = 'en-US';
  static const double _speakingRate = 0.9; // Slightly slower, professorial
  static const double _pitch = -2.0; // Deeper voice for authority
  static const String _audioEncoding = 'MP3';

  VoiceService(this._remoteConfigService);

  /// Initializes Speech-to-Text
  Future<bool> initialize() async {
    try {
      // Initialize Speech-to-Text
      final sttAvailable = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );

      if (!sttAvailable) {
        debugPrint('Speech recognition not available');
        return false;
      }

      // Configure audio player
      await _configureAudioPlayer();

      // Configure fallback TTS
      await _configureFlutterTts();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Voice service initialization error: $e');
      return false;
    }
  }

  /// Configures audio player settings
  Future<void> _configureAudioPlayer() async {
    // Set audio player to release mode for one-time playback
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _isSpeaking = false;
      }
    });
  }

  /// Configures Flutter TTS as fallback
  Future<void> _configureFlutterTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.45); // Flutter TTS rate (0.0-1.0)
      await _flutterTts.setPitch(0.8); // Flutter TTS pitch (0.5-2.0, lower is deeper)
      await _flutterTts.setVolume(1.0);
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      debugPrint('Flutter TTS configured as fallback');
    } catch (e) {
      debugPrint('Error configuring Flutter TTS: $e');
    }
  }

  /// Starts listening to user speech
  /// Returns transcribed text via callback
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      onError('Voice service not initialized');
      return;
    }

    if (_isListening) {
      return;
    }

    try {
      // Stop any ongoing speech
      await stopSpeaking();

      _isListening = true;
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      onError('Failed to start listening: $e');
    }
  }

  /// Stops listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Speaks text using Google Cloud Text-to-Speech (Wavenet)
  /// Falls back to local Flutter TTS if cloud API fails
  /// Returns true if successful, false otherwise
  Future<bool> speak(String text, {Function(String)? onStatusUpdate}) async {
    if (!_isInitialized) {
      debugPrint('Voice service not initialized');
      return false;
    }

    if (text.trim().isEmpty) {
      debugPrint('Cannot speak empty text');
      return false;
    }

    try {
      // Stop any ongoing speech first
      await stopSpeaking();

      // Update status: fetching audio from cloud
      _isFetchingAudio = true;
      onStatusUpdate?.call('Professor is preparing to speak...');

      // Try Google Cloud TTS first
      final audioBytes = await _fetchAudioFromGoogleCloud(text);
      
      if (audioBytes != null) {
        _isFetchingAudio = false;
        _isSpeaking = true;
        onStatusUpdate?.call('Speaking...');

        // Play the audio
        await _audioPlayer.play(BytesSource(audioBytes));
        
        return true;
      } else {
        // Fallback to Flutter TTS if cloud TTS failed
        debugPrint('Cloud TTS failed, falling back to local TTS');
        return await _speakWithFlutterTts(text, onStatusUpdate);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isFetchingAudio = false;
      
      // Try fallback to Flutter TTS
      try {
        return await _speakWithFlutterTts(text, onStatusUpdate);
      } catch (fallbackError) {
        debugPrint('Fallback TTS also failed: $fallbackError');
        _isSpeaking = false;
        onStatusUpdate?.call('Error generating speech');
        return false;
      }
    }
  }
  /// Generates speech audio and saves to Firebase Storage
  /// Returns the Firebase Storage download URL
  /// This is for the Audio Archive feature
  Future<String> generateSpeech({
    required String text,
    required String userId,
  }) async {
    if (!_isInitialized) {
      throw VoiceServiceException('Voice service not initialized');
    }

    if (text.trim().isEmpty) {
      throw VoiceServiceException('Cannot generate speech for empty text');
    }

    try {
      // Fetch audio from Google Cloud TTS
      final audioBytes = await _fetchAudioFromGoogleCloud(text);
      
      if (audioBytes == null) {
        throw VoiceServiceException('Failed to generate audio from cloud TTS');
      }

      // Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'audio_$timestamp.mp3';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('audio_archive')
          .child(userId)
          .child(fileName);

      debugPrint('Uploading audio to Firebase Storage: $fileName (${audioBytes.length} bytes)');

      // Upload the file
      final uploadTask = await storageRef.putData(
        audioBytes,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'generatedAt': timestamp.toString(),
            'textLength': text.length.toString(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      debugPrint('Audio uploaded successfully to Firebase Storage');
      debugPrint('Download URL: $downloadUrl');
      
      return downloadUrl;
      
    } catch (e) {
      debugPrint('Error generating speech: $e');
      throw VoiceServiceException('Failed to generate speech: $e');
    }
  }

  /// Fallback TTS using Flutter TTS
  Future<bool> _speakWithFlutterTts(String text, Function(String)? onStatusUpdate) async {
    try {
      _isFetchingAudio = false;
      _isSpeaking = true;
      onStatusUpdate?.call('Speaking (offline mode)...');
      
      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      debugPrint('Flutter TTS error: $e');
      _isSpeaking = false;
      onStatusUpdate?.call('Error generating speech');
      return false;
    }
  }

  /// Fetches audio bytes from Google Cloud Text-to-Speech API
  /// Uses Remote Config for API key and voice name
  Future<Uint8List?> _fetchAudioFromGoogleCloud(String text) async {
    try {
      // Get API key from Remote Config with fallback to local constant
      final apiKey = _remoteConfigService.getGoogleCloudTtsApiKey(
        AppConstants.googleCloudTtsApiKey
      );
      
      if (apiKey == 'YOUR_GOOGLE_CLOUD_TTS_API_KEY' || apiKey.isEmpty) {
        debugPrint('Google Cloud TTS API key not configured');
        return null; // Will trigger fallback to Flutter TTS
      }

      // Get voice name from Remote Config
      final voiceName = _remoteConfigService.getTtsVoiceName();

      final url = Uri.parse('$_ttsEndpoint?key=$apiKey');
      
      final requestBody = {
        'input': {'text': text},
        'voice': {
          'languageCode': _languageCode,
          'name': voiceName,
          'ssmlGender': 'MALE',
        },
        'audioConfig': {
          'audioEncoding': _audioEncoding,
          'speakingRate': _speakingRate,
          'pitch': _pitch,
          'volumeGainDb': 0.0,
          'sampleRateHertz': 24000,
        },
      };

      debugPrint('Requesting TTS from Google Cloud with voice: $voiceName');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Google Cloud TTS request timed out');
          throw VoiceServiceException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final audioContent = jsonResponse['audioContent'] as String;
        
        // Decode base64 audio
        final audioBytes = base64.decode(audioContent);
        debugPrint('Successfully received ${audioBytes.length} bytes of audio from Google Cloud TTS');
        
        return audioBytes;
      } else {
        debugPrint('TTS API Error: ${response.statusCode} - ${response.body}');
        return null; // Will trigger fallback to Flutter TTS
      }
    } catch (e) {
      debugPrint('Error fetching audio from Google Cloud: $e');
      return null; // Will trigger fallback to Flutter TTS
    }
  }

  /// Stops speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _audioPlayer.stop();
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  /// Pauses speaking
  Future<void> pauseSpeaking() async {
    if (_isSpeaking) {
      await _audioPlayer.pause();
    }
  }

  /// Resumes speaking
  Future<void> resumeSpeaking() async {
    if (_isSpeaking) {
      await _audioPlayer.resume();
    }
  }

  /// Checks if speech recognition is available
  Future<bool> isSpeechAvailable() async {
    return await _speechToText.initialize();
  }

  /// Gets available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    return await _speechToText.locales();
  }

  /// Disposes resources
  void dispose() {
    _speechToText.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
  }
}

/// Custom exception for Voice Service errors
class VoiceServiceException implements Exception {
  final String message;
  VoiceServiceException(this.message);

  @override
  String toString() => message;
}
