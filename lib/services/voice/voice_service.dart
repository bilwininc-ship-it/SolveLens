// Voice Service for Speech-to-Text and Text-to-Speech
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  /// Initializes both STT and TTS
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

      // Configure TTS with Professor voice parameters
      await _configureTts();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Voice service initialization error: $e');
      return false;
    }
  }

  /// Configures TTS with calm Professor voice
  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5); // Natural speaking rate
    await _flutterTts.setVolume(1.0); // Full volume
    await _flutterTts.setPitch(0.95); // Slightly lower pitch for authority
    
    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    // Set error handler
    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
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

  /// Speaks text using TTS
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint('TTS not initialized');
      return;
    }

    try {
      // Stop any ongoing speech first
      await stopSpeaking();

      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isSpeaking = false;
    }
  }

  /// Stops speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  /// Pauses speaking
  Future<void> pauseSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
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
