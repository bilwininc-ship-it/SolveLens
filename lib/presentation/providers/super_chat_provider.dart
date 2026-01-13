// Provider for Super Chat - Premium AI Chat Interface
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../services/ai/ai_service.dart';
import '../../services/voice/voice_service.dart';
import '../../services/quota/quota_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/quota_model.dart';
import 'super_chat_state.dart';

class SuperChatProvider extends ChangeNotifier {
  final AIService aiService;
  final VoiceService voiceService;
  final QuotaService quotaService;
  final String userId;

  SuperChatState _state = const SuperChatInitial();
  SuperChatState get state => _state;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  QuotaModel? _currentQuota;
  QuotaModel? get currentQuota => _currentQuota;

  final _uuid = const Uuid();

  SuperChatProvider({
    required this.aiService,
    required this.voiceService,
    required this.quotaService,
    required this.userId,
  }) {
    _initializeQuota();
  }

  /// Initialize quota from service
  Future<void> _initializeQuota() async {
    try {
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = _convertToQuotaModel(usage);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing quota: $e');
      _currentQuota = QuotaModel.freeTier();
    }
  }

  /// Stream quota updates in real-time
  Stream<QuotaModel> streamQuota() {
    return quotaService.streamQuotaUsage(userId).map((usage) => _convertToQuotaModel(usage));
  }

  /// Converts QuotaUsage to QuotaModel
  QuotaModel _convertToQuotaModel(dynamic usage) {
    return QuotaModel(
      textQuestionsUsed: usage.textMessagesUsed,
      textQuestionsLimit: usage.textMessagesLimit,
      voiceMinutesUsed: usage.voiceMinutesUsed.toInt(),
      voiceMinutesLimit: usage.voiceMinutesLimit.toInt(),
      imageScansUsed: 0, // Not tracked in current QuotaUsage
      imageScansLimit: 10, // Default
      resetDate: usage.weekStart,
    );
  }

  /// Send text message
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Check quota
      if (_currentQuota != null && !_currentQuota!.hasTextQuota) {
        _setState(SuperChatQuotaExceeded(
          messages: _messages,
          quotaType: 'text',
        ));
        return;
      }

      // Add user message
      final userMessage = ChatMessageModel.userText(
        id: _uuid.v4(),
        text: text.trim(),
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Professor is analyzing your question...',
      ));

      // Get AI response (using text-only chat method)
      final response = await aiService.getChatResponse(text.trim());

      // Check if response includes audio URL (for voice response)
      final hasAudio = response.contains('audio_url:');
      String responseText = response;
      String? audioUrl;

      if (hasAudio) {
        final parts = response.split('audio_url:');
        responseText = parts[0].trim();
        audioUrl = parts[1].trim();
      }

      // Add professor message
      final professorMessage = hasAudio
          ? ChatMessageModel.professorAudio(
              id: _uuid.v4(),
              text: responseText,
              audioUrl: audioUrl!,
            )
          : ChatMessageModel.professorText(
              id: _uuid.v4(),
              text: responseText,
            );

      _messages.add(professorMessage);

      // Update quota
      await quotaService.incrementTextMessage(userId);
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = _convertToQuotaModel(usage);

      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Failed to send message: $e',
      ));
    }
  }

  /// Send image message
  Future<void> sendImageMessage(File imageFile, {String text = ''}) async {
    try {
      // Check quota
      if (_currentQuota != null && !_currentQuota!.hasImageQuota) {
        _setState(SuperChatQuotaExceeded(
          messages: _messages,
          quotaType: 'image',
        ));
        return;
      }

      // Add user message with image
      final userMessage = ChatMessageModel.userImage(
        id: _uuid.v4(),
        imageFile: imageFile,
        text: text,
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Professor is analyzing the image...',
      ));

      // Analyze image with AI
      final response = await aiService.analyzeImage(
        imageFile,
        prompt: text.isNotEmpty ? text : 'Please analyze this image and provide a detailed explanation.',
      );

      // Add professor response
      final professorMessage = ChatMessageModel.professorText(
        id: _uuid.v4(),
        text: response,
      );
      _messages.add(professorMessage);

      // Update quota (images count as text messages in current implementation)
      await quotaService.incrementTextMessage(userId);
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = _convertToQuotaModel(usage);

      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Failed to analyze image: $e',
      ));
    }
  }

  /// Send voice message (transcribed text)
  Future<void> sendVoiceMessage(String transcribedText, double durationMinutes) async {
    if (transcribedText.trim().isEmpty) return;

    try {
      // Check quota
      if (_currentQuota != null && !_currentQuota!.hasVoiceQuota) {
        _setState(SuperChatQuotaExceeded(
          messages: _messages,
          quotaType: 'voice',
        ));
        return;
      }

      // Add user voice message
      final userMessage = ChatMessageModel.userVoice(
        id: _uuid.v4(),
        transcribedText: transcribedText.trim(),
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Professor is preparing an audio response...',
      ));

      // Get AI response text
      final responseText = await aiService.getChatResponse(transcribedText.trim());

      // Generate audio response
      final audioUrl = await voiceService.generateSpeech(
        text: responseText,
        userId: userId,
      );

      // Add professor audio message
      final professorMessage = ChatMessageModel.professorAudio(
        id: _uuid.v4(),
        text: responseText,
        audioUrl: audioUrl,
      );
      _messages.add(professorMessage);

      // Update quota (increment by duration in minutes)
      await quotaService.incrementVoiceMinutes(userId, durationMinutes);
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = _convertToQuotaModel(usage);

      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Failed to process voice message: $e',
      ));
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _setState(const SuperChatInitial());
  }

  /// Refresh quota
  Future<void> refreshQuota() async {
    try {
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = _convertToQuotaModel(usage);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing quota: $e');
    }
  }

  void _setState(SuperChatState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    _currentQuota = null;
    super.dispose();
  }
}
