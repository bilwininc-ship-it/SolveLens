// SuperChat Provider - manages chat state and logic
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../services/ai/ai_service.dart';
import '../../services/voice/voice_service.dart';
import '../../services/quota/quota_service.dart';
import 'super_chat_state.dart';
import 'user_provider.dart';

class SuperChatProvider extends ChangeNotifier {
  final AIService aiService;
  final VoiceService voiceService;
  final QuotaService quotaService;
  final String userId;
  final UserProvider userProvider;

  SuperChatState _state = const SuperChatInitial();
  SuperChatState get state => _state;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  QuotaUsage? _currentQuota;
  QuotaUsage? get currentQuota => _currentQuota;

  SuperChatProvider({
    required this.aiService,
    required this.voiceService,
    required this.quotaService,
    required this.userId,
    required this.userProvider,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _currentQuota = await quotaService.getQuotaUsage(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SuperChatProvider: $e');
    }
  }

  /// Stream quota updates
  Stream<QuotaUsage> streamQuota() {
    return quotaService.streamQuotaUsage(userId);
  }

  /// Send a text message
  Future<void> sendTextMessage(
    String text, {
    ChatMode mode = ChatMode.textToText,
  }) async {
    if (text.trim().isEmpty) return;

    // Check quota
    if (_currentQuota != null && !_currentQuota!.hasTextQuota) {
      _setState(SuperChatQuotaExceeded(
        messages: _messages,
        quotaType: 'text',
      ));
      return;
    }

    // Add user message
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      mode: mode,
    );
    _messages.add(userMessage);
    _setState(SuperChatLoaded(messages: _messages));

    // Set processing state
    _setState(SuperChatProcessing(
      messages: _messages,
      processingMessage: 'Professor is thinking...',
    ));

    try {
      // Get AI response based on mode
      String? responseText;
      
      if (mode == ChatMode.textToText || mode == ChatMode.voiceToText) {
        responseText = await aiService.getChatResponse(text);
      } else if (mode == ChatMode.textToVoice || mode == ChatMode.liveVoiceChat) {
        // For voice output modes, get text first then convert to voice
        responseText = await aiService.getChatResponse(text);
        // TODO: Convert to voice if needed
      }

      if (responseText != null) {
        // Add AI response
        final aiMessage = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          mode: mode,
        );
        _messages.add(aiMessage);

        // Update quota
        await quotaService.incrementTextMessage(userId);
        _currentQuota = await quotaService.getQuotaUsage(userId);

        _setState(SuperChatLoaded(messages: _messages));
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Send an image message
  Future<void> sendImageMessage(
    File imageFile, {
    String? text,
  }) async {
    // Check quota
    if (_currentQuota != null && !_currentQuota!.hasTextQuota) {
      _setState(SuperChatQuotaExceeded(
        messages: _messages,
        quotaType: 'image',
      ));
      return;
    }

    // Add user message with image
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text ?? 'Sent an image',
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageFile.path,
    );
    _messages.add(userMessage);
    _setState(SuperChatLoaded(messages: _messages));

    // Set processing state
    _setState(SuperChatProcessing(
      messages: _messages,
      processingMessage: 'Analyzing image...',
    ));

    try {
      // Analyze image with AI
      final responseText = await aiService.analyzeImage(
        imageFile,
        prompt: text,
      );

      if (responseText != null) {
        // Add AI response
        final aiMessage = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);

        // Update quota (images use text quota)
        await quotaService.incrementTextMessage(userId);
        _currentQuota = await quotaService.getQuotaUsage(userId);

        _setState(SuperChatLoaded(messages: _messages));
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Error analyzing image: $e',
      ));
    }
  }

  /// Send a voice message
  Future<void> sendVoiceMessage(
    String transcribedText,
    double durationMinutes, {
    ChatMode mode = ChatMode.voiceToText,
  }) async {
    if (transcribedText.trim().isEmpty) return;

    // Check quota
    if (_currentQuota != null && !_currentQuota!.hasVoiceQuota) {
      _setState(SuperChatQuotaExceeded(
        messages: _messages,
        quotaType: 'voice',
      ));
      return;
    }

    // Add user message
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: transcribedText,
      isUser: true,
      timestamp: DateTime.now(),
      mode: mode,
      isVoice: true,
    );
    _messages.add(userMessage);
    _setState(SuperChatLoaded(messages: _messages));

    // Set processing state
    _setState(SuperChatProcessing(
      messages: _messages,
      processingMessage: 'Professor is thinking...',
    ));

    try {
      // Get AI response
      final responseText = await aiService.getChatResponse(transcribedText);

      if (responseText != null) {
        // Add AI response
        final aiMessage = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          mode: mode,
        );
        _messages.add(aiMessage);

        // Update quota
        await quotaService.incrementVoiceMinutes(userId, durationMinutes);
        _currentQuota = await quotaService.getQuotaUsage(userId);

        _setState(SuperChatLoaded(messages: _messages));
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Send a PDF message
  Future<void> sendPDFMessage(
    File pdfFile,
    String fileName,
    int fileSize,
  ) async {
    // Check quota
    if (_currentQuota != null && !_currentQuota!.hasTextQuota) {
      _setState(SuperChatQuotaExceeded(
        messages: _messages,
        quotaType: 'pdf',
      ));
      return;
    }

    // Add user message with PDF
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Sent a PDF: $fileName',
      isUser: true,
      timestamp: DateTime.now(),
      pdfUrl: pdfFile.path,
    );
    _messages.add(userMessage);
    _setState(SuperChatLoaded(messages: _messages));

    // Set processing state
    _setState(SuperChatProcessing(
      messages: _messages,
      processingMessage: 'Analyzing PDF...',
    ));

    try {
      // Analyze PDF with AI
      final responseText = await aiService.analyzePDF(pdfFile);

      if (responseText != null) {
        // Add AI response
        final aiMessage = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);

        // Update quota (PDFs use text quota)
        await quotaService.incrementTextMessage(userId);
        _currentQuota = await quotaService.getQuotaUsage(userId);

        _setState(SuperChatLoaded(messages: _messages));
      } else {
        throw Exception('Failed to analyze PDF');
      }
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Error analyzing PDF: $e',
      ));
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _setState(const SuperChatInitial());
  }

  /// Load messages for a conversation
  Future<void> loadConversationMessages(String conversationId) async {
    try {
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Loading conversation...',
      ));

      // TODO: Load messages from Firestore
      // For now, just set to loaded state
      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Error loading conversation: $e',
      ));
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
