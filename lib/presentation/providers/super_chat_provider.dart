// Provider for Super Chat - Premium AI Chat Interface
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../services/ai/ai_service.dart';
import '../../services/voice/voice_service.dart';
import '../../services/quota/quota_service.dart';
import '../../data/models/chat_message_model.dart';
import 'super_chat_state.dart';

class SuperChatProvider extends ChangeNotifier {
  final AIService aiService;
  final VoiceService voiceService;
  final QuotaService quotaService;
  final String userId;
  final dynamic userProvider; // UserProvider reference for credit system

  SuperChatState _state = const SuperChatInitial();
  SuperChatState get state => _state;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  QuotaUsage? _currentQuota;
  QuotaUsage? get currentQuota => _currentQuota;

  final _uuid = const Uuid();
  
  // Store last extracted PDF text for debugging
  String? lastExtractedText;

  SuperChatProvider({
    required this.aiService,
    required this.voiceService,
    required this.quotaService,
    required this.userId,
    required this.userProvider, // NEW: UserProvider for credit deduction
  }) {
    _initializeQuota();
  }

  /// Initialize quota from service
  Future<void> _initializeQuota() async {
    try {
      final usage = await quotaService.getQuotaUsage(userId);
      _currentQuota = usage;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing quota: $e');
      // Set default quota if error occurs
      _currentQuota = QuotaUsage(
        textMessagesUsed: 0,
        voiceMinutesUsed: 0,
        textMessagesLimit: 150,
        voiceMinutesLimit: 15.0,
        weekStart: DateTime.now(),
        monthStart: DateTime.now(),
      );
    }
  }

  /// Stream quota updates in real-time
  Stream<QuotaUsage> streamQuota() {
    return quotaService.streamQuotaUsage(userId);
  }

  /// Send text message
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // ============================================================
      // NEW CREDIT SYSTEM: Check if user has credits
      // ============================================================
      if (userProvider.remainingCredits <= 0) {
        _setState(SuperChatError(
          messages: _messages,
          errorMessage: '💳 Insufficient credits! Please purchase more credits to continue.',
        ));
        return;
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // final usage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = usage;
      // 
      // if (!usage.hasTextQuota) {
      //   _setState(SuperChatQuotaExceeded(
      //     messages: _messages,
      //     quotaType: 'text',
      //   ));
      //   return;
      // }

      // Add user message
      final userMessage = ChatMessageModel.userText(
        id: _uuid.v4(),
        text: text.trim(),
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Elite Professor is analyzing your question...',
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

      // ============================================================
      // NEW CREDIT SYSTEM: Deduct 1 credit for text message
      // ============================================================
      final deductionSuccess = await userProvider.useCredits(1);
      if (!deductionSuccess) {
        debugPrint('⚠️ Warning: Credit deduction failed for text message');
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // await quotaService.incrementTextMessage(userId);
      // final updatedUsage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = updatedUsage;

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
      // ============================================================
      // NEW CREDIT SYSTEM: Check if user has credits
      // ============================================================
      if (userProvider.remainingCredits <= 0) {
        _setState(SuperChatError(
          messages: _messages,
          errorMessage: '💳 Insufficient credits! Please purchase more credits to continue.',
        ));
        return;
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // final usage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = usage;
      // 
      // if (!usage.hasTextQuota) {
      //   _setState(SuperChatQuotaExceeded(
      //     messages: _messages,
      //     quotaType: 'image',
      //   ));
      //   return;
      // }

      // Add user message with image
      final userMessage = ChatMessageModel.userImage(
        id: _uuid.v4(),
        imageFile: imageFile,
        text: text,
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Elite Professor is analyzing the image...',
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

      // ============================================================
      // NEW CREDIT SYSTEM: Deduct 1 credit for image analysis
      // ============================================================
      final deductionSuccess = await userProvider.useCredits(1);
      if (!deductionSuccess) {
        debugPrint('⚠️ Warning: Credit deduction failed for image message');
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // await quotaService.incrementTextMessage(userId);
      // final updatedUsage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = updatedUsage;

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
      // ============================================================
      // NEW CREDIT SYSTEM: Check if user has credits
      // ============================================================
      if (userProvider.remainingCredits <= 0) {
        _setState(SuperChatError(
          messages: _messages,
          errorMessage: '💳 Insufficient credits! Please purchase more credits to continue.',
        ));
        return;
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // final usage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = usage;
      // 
      // if (!usage.hasVoiceQuota) {
      //   _setState(SuperChatQuotaExceeded(
      //     messages: _messages,
      //     quotaType: 'voice',
      //   ));
      //   return;
      // }

      // Add user voice message
      final userMessage = ChatMessageModel.userVoice(
        id: _uuid.v4(),
        transcribedText: transcribedText.trim(),
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Elite Professor is preparing an audio response...',
      ));

      // Get AI response text (Gemini API call)
      final responseText = await aiService.getChatResponse(transcribedText.trim());

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // Check quota again before expensive TTS operation
      // final currentUsage = await quotaService.getQuotaUsage(userId);
      // if (!currentUsage.hasVoiceQuota) {
      //   // Add text-only response if voice quota exhausted
      //   final professorMessage = ChatMessageModel.professorText(
      //     id: _uuid.v4(),
      //     text: responseText + '\n\n⚠️ Voice quota exhausted. Upgrade for audio responses!',
      //   );
      //   _messages.add(professorMessage);
      //   _setState(SuperChatLoaded(messages: _messages));
      //   return;
      // }

      // Generate audio response (Google Cloud TTS + Firebase Storage upload)
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

      // ============================================================
      // NEW CREDIT SYSTEM: Deduct 1 credit for voice message
      // ============================================================
      final deductionSuccess = await userProvider.useCredits(1);
      if (!deductionSuccess) {
        debugPrint('⚠️ Warning: Credit deduction failed for voice message');
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // await quotaService.incrementVoiceMinutes(userId, durationMinutes);
      // final updatedUsage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = updatedUsage;

      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Failed to process voice message: $e',
      ));
    }
  }

  /// Extract text from PDF (max 50 pages)
  Future<String> _extractPdfText(File file) async {
    PdfDocument? document;
    try {
      // Load PDF document
      final bytes = await file.readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      
      // Get total pages (max 50)
      final totalPages = document.pages.count;
      final pagesToProcess = totalPages > 50 ? 50 : totalPages;
      
      // Extract text from each page
      final StringBuffer textBuffer = StringBuffer();
      for (int i = 0; i < pagesToProcess; i++) {
        final PdfPage page = document.pages[i];
        final String pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        textBuffer.write(pageText);
        textBuffer.write('\n'); // Add newline between pages
      }
      
      return textBuffer.toString();
    } catch (e) {
      debugPrint('Error extracting PDF text: $e');
      return '';
    } finally {
      // Dispose document to free memory
      document?.dispose();
    }
  }

  /// Send PDF message
  Future<void> sendPDFMessage(File pdfFile, String fileName, String fileSize, {String text = ''}) async {
    try {
      // ============================================================
      // NEW CREDIT SYSTEM: Check if user has credits (PDF requires 3 credits)
      // ============================================================
      if (userProvider.remainingCredits < 3) {
        _setState(SuperChatError(
          messages: _messages,
          errorMessage: '💳 Insufficient credits! PDF analysis requires 3 credits. Please purchase more credits to continue.',
        ));
        return;
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // final usage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = usage;
      // 
      // if (!usage.hasTextQuota) {
      //   _setState(SuperChatQuotaExceeded(
      //     messages: _messages,
      //     quotaType: 'pdf',
      //   ));
      //   return;
      // }

      // Add user message with PDF
      final userMessage = ChatMessageModel.userPDF(
        id: _uuid.v4(),
        pdfFile: pdfFile,
        pdfFileName: fileName,
        pdfFileSize: fileSize,
        text: text,
      );
      _messages.add(userMessage);
      _setState(SuperChatProcessing(
        messages: _messages,
        processingMessage: 'Elite Professor is analyzing the PDF document...',
      ));

      // Extract PDF text
      final extractedText = await _extractPdfText(pdfFile);
      
      // Store extracted text for debugging
      lastExtractedText = extractedText;
      
      // Print first 100 characters to console
      final preview = extractedText.length > 100 
          ? extractedText.substring(0, 100) 
          : extractedText;
      debugPrint('PDF Text Preview (first 100 chars): $preview');

      // Check if PDF text was successfully extracted
      if (extractedText.isEmpty) {
        throw Exception('Could not extract text from PDF. The PDF might be image-based or encrypted.');
      }

      // Send extracted text to Gemini AI for analysis
      final userQuery = text.isNotEmpty 
          ? text 
          : 'Please analyze this PDF document and provide a comprehensive summary with key insights.';
      
      final fullPrompt = '''
$userQuery

Here is the content from the PDF document "$fileName":

$extractedText
''';

      debugPrint('Sending ${extractedText.length} characters to Gemini AI for analysis...');
      
      // Get AI response from Gemini
      final response = await aiService.getChatResponse(fullPrompt);

      // Add professor response
      final professorMessage = ChatMessageModel.professorText(
        id: _uuid.v4(),
        text: response,
      );
      _messages.add(professorMessage);

      // ============================================================
      // NEW CREDIT SYSTEM: Deduct 3 credits for PDF analysis (brain-heavy task)
      // ============================================================
      final deductionSuccess = await userProvider.useCredits(3);
      if (!deductionSuccess) {
        debugPrint('⚠️ Warning: Credit deduction failed for PDF message');
      }

      // ============================================================
      // OLD QUOTA SYSTEM (COMMENTED OUT - TO BE REMOVED LATER)
      // ============================================================
      // await quotaService.incrementTextMessage(userId);
      // final updatedUsage = await quotaService.getQuotaUsage(userId);
      // _currentQuota = updatedUsage;

      _setState(SuperChatLoaded(messages: _messages));
    } catch (e) {
      _setState(SuperChatError(
        messages: _messages,
        errorMessage: 'Failed to process PDF: $e',
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
      _currentQuota = usage;
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
