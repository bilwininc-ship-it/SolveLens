// Voice Chat Screen - Voice-powered AI Mentor with STT and Google Cloud TTS
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../services/voice/voice_service.dart';
import '../../../services/ai/ai_service.dart';
import '../../../core/di/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with TickerProviderStateMixin {
  final VoiceService _voiceService = getIt<VoiceService>();
  final AIService _aiService = getIt<AIService>();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isFetchingAudio = false;
  bool _isProcessing = false;
  bool _isInitialized = false;
  String _currentText = '';
  String _statusMessage = 'Tap to speak with Professor';
  List<ChatMessage> _messages = [];
  
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingRotation;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for microphone
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Loading animation for audio fetching
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _loadingRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeVoiceService() async {
    final success = await _voiceService.initialize();
    setState(() {
      _isInitialized = success;
      _statusMessage = success 
          ? 'Ready! Tap to speak with Professor'
          : 'Voice service unavailable';
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _pulseAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      _showSnackBar('Voice service not available');
      return;
    }

    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _currentText = '';
      _statusMessage = 'Listening... Speak now';
    });

    await _voiceService.startListening(
      onResult: (text) {
        setState(() {
          _currentText = text;
        });
        _processUserInput(text);
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _statusMessage = 'Error: $error';
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _statusMessage = _currentText.isEmpty 
          ? 'Tap to speak with Professor'
          : 'Processing...';
    });
  }

  Future<void> _processUserInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Professor is thinking...';
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get AI response
      final response = await _getAITextResponse(text, user.uid);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });

      // Speak the response using Google Cloud TTS
      await _speakResponse(response);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
      _showSnackBar('Failed to get response: $e');
    }
  }

  /// Gets AI response for text-based questions
  Future<String> _getAITextResponse(String question, String userId) async {
    // For voice chat, we create a simplified response
    // You could enhance this to use a dedicated text-only AI endpoint
    
    // Simplified response for voice chat (you may want to create a separate method in AIService)
    return '''Let me help you with that.

For voice chat, I recommend taking a photo of your question so I can see the complete problem and provide a detailed step-by-step solution with proper mathematical notation.

However, based on what you asked: "$question"

I can provide general guidance. Could you please clarify:
1. What subject is this related to?
2. What specific concept are you struggling with?

For the best learning experience, use the camera feature to scan your homework question!''';
  }

  Future<void> _speakResponse(String text) async {
    // Clean text for TTS (remove markdown and LaTeX)
    String cleanText = text
        .replaceAll(RegExp(r'\\\[.*?\\\]', dotAll: true), 'mathematical equation')
        .replaceAll(RegExp(r'\\\(.*?\\\)', dotAll: true), 'math expression')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'__'), '')
        .replaceAll(RegExp(r'\n+'), '. ');

    // Speak with Google Cloud TTS and get status updates
    final success = await _voiceService.speak(
      cleanText,
      onStatusUpdate: (status) {
        setState(() {
          _statusMessage = status;
          _isFetchingAudio = status.contains('preparing');
          _isSpeaking = status.contains('Speaking');
        });
      },
    );

    if (success) {
      // Wait for speaking to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check periodically if still speaking
      while (_voiceService.isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    setState(() {
      _isFetchingAudio = false;
      _isSpeaking = false;
      _statusMessage = 'Tap to continue conversation';
    });
  }

  Future<void> _stopSpeaking() async {
    await _voiceService.stopSpeaking();
    setState(() {
      _isSpeaking = false;
      _isFetchingAudio = false;
      _statusMessage = 'Tap to speak with Professor';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      appBar: AppBar(
        backgroundColor: AppTheme.navyDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Voice Mentor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _currentText = '';
                  _statusMessage = 'Tap to speak with Professor';
                });
              },
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessagesList(),
          ),
          
          // Voice control interface
          _buildVoiceControls(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.3),
                    Colors.blue.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.blue,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Voice Professor',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask questions using your voice and get spoken explanations',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Powered by Google Cloud Wavenet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'For detailed solutions with math equations,\nuse the Camera feature to scan your questions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: false,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue.withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isUser
                ? Colors.blue.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Widget _buildVoiceControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status message with loading indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isFetchingAudio)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: RotationTransition(
                      turns: _loadingRotation,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Voice control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Stop speaking button
                if (_isSpeaking || _isFetchingAudio)
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    color: Colors.red,
                    onTap: _stopSpeaking,
                  ),
                
                // Main microphone button
                GestureDetector(
                  onTap: (_isProcessing || _isSpeaking || _isFetchingAudio) ? null : _toggleListening,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isListening
                                  ? [Colors.red, Colors.red.shade700]
                                  : _isFetchingAudio
                                      ? [Colors.orange, Colors.orange.shade700]
                                      : [Colors.blue, Colors.blue.shade700],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening 
                                    ? Colors.red 
                                    : _isFetchingAudio 
                                        ? Colors.orange 
                                        : Colors.blue)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening 
                                ? Icons.mic 
                                : _isFetchingAudio
                                    ? Icons.cloud_download
                                    : Icons.mic_none,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Placeholder for symmetry or help button
                if (_isSpeaking || _isFetchingAudio)
                  const SizedBox(width: 80)
                else if (!_isListening)
                  _buildControlButton(
                    icon: Icons.info_outline,
                    label: 'Help',
                    color: Colors.grey,
                    onTap: () {
                      _showSnackBar('Tap the microphone to ask questions with your voice');
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Current transcription
            if (_currentText.isNotEmpty && _isListening)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _currentText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
