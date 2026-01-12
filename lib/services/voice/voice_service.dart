// Voice Service for Speech-to-Text and Google Cloud Text-to-Speech
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../../core/constants/app_constants.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isFetchingAudio = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isFetchingAudio => _isFetchingAudio;
  bool get isInitialized => _isInitialized;

  // Google Cloud TTS configuration
  static const String _ttsEndpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  static const String _voiceName = 'en-US-Wavenet-D'; // Deep, authoritative male voice
  static const String _languageCode = 'en-US';
  static const double _speakingRate = 0.9; // Slightly slower, professorial
  static const double _pitch = -2.0; // Deeper voice for authority
  static const String _audioEncoding = 'MP3';

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

      // Get audio from Google Cloud TTS
      final audioBytes = await _fetchAudioFromGoogleCloud(text);
      
      if (audioBytes == null) {
        _isFetchingAudio = false;
        onStatusUpdate?.call('Failed to generate speech');
        return false;
      }

      _isFetchingAudio = false;
      _isSpeaking = true;
      onStatusUpdate?.call('Speaking...');

      // Play the audio
      await _audioPlayer.play(BytesSource(audioBytes));
      
      return true;
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isFetchingAudio = false;
      _isSpeaking = false;
      onStatusUpdate?.call('Error generating speech');
      return false;
    }
  }

  /// Fetches audio bytes from Google Cloud Text-to-Speech API
  Future<Uint8List?> _fetchAudioFromGoogleCloud(String text) async {
    try {
      final apiKey = AppConstants.googleCloudTtsApiKey;
      
      if (apiKey == 'YOUR_GOOGLE_CLOUD_TTS_API_KEY') {
        throw VoiceServiceException(
          'Google Cloud TTS API key not configured. Please add your API key to app_constants.dart'
        );
      }

      final url = Uri.parse('$_ttsEndpoint?key=$apiKey');
      
      final requestBody = {
        'input': {'text': text},
        'voice': {
          'languageCode': _languageCode,
          'name': _voiceName,
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

      debugPrint('Requesting TTS from Google Cloud with voice: $_voiceName');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final audioContent = jsonResponse['audioContent'] as String;
        
        // Decode base64 audio
        final audioBytes = base64.decode(audioContent);
        debugPrint('Successfully received ${audioBytes.length} bytes of audio');
        
        return audioBytes;
      } else {
        debugPrint('TTS API Error: ${response.statusCode} - ${response.body}');
        throw VoiceServiceException(
          'Failed to generate speech: ${response.statusCode}'
        );
      }
    } catch (e) {
      debugPrint('Error fetching audio from Google Cloud: $e');
      throw VoiceServiceException('Failed to fetch audio: $e');
    }
  }

  /// Stops speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _audioPlayer.stop();
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
  }
}

/// Custom exception for Voice Service errors
class VoiceServiceException implements Exception {
  final String message;
  VoiceServiceException(this.message);

  @override
  String toString() => message;
}
