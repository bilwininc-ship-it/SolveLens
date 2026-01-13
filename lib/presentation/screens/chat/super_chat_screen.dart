// Super Chat Screen - Unified Premium Chat Interface
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/di/service_locator.dart';
import '../../../services/ai/ai_service.dart';
import '../../../services/voice/voice_service.dart';
import '../../../services/quota/quota_service.dart';
import '../../providers/super_chat_provider.dart';
import '../../providers/super_chat_state.dart';
import '../../widgets/chat/quota_indicator.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/hybrid_input_bar.dart';

class SuperChatScreen extends StatefulWidget {
  const SuperChatScreen({super.key});

  @override
  State<SuperChatScreen> createState() => _SuperChatScreenState();
}

class _SuperChatScreenState extends State<SuperChatScreen> {
  late SuperChatProvider _chatProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChatProvider();
  }

  void _initializeChatProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle not logged in
      return;
    }

    _chatProvider = SuperChatProvider(
      aiService: getIt<AIService>(),
      voiceService: getIt<VoiceService>(),
      quotaService: getIt<QuotaService>(),
      userId: user.uid,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatProvider.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleSendText(String text) {
    _chatProvider.sendTextMessage(text);
    _scrollToBottom();
  }

  void _handleSendImage(file, caption) {
    _chatProvider.sendImageMessage(file, text: caption);
    _scrollToBottom();
  }

  void _handleSendVoice(String transcribedText, double durationMinutes) {
    _chatProvider.sendVoiceMessage(transcribedText, durationMinutes);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SuperChatProvider>.value(
      value: _chatProvider,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Quota Indicator
            Consumer<SuperChatProvider>(
              builder: (context, provider, child) {
                return StreamBuilder(
                  stream: provider.streamQuota(),
                  builder: (context, snapshot) {
                    return QuotaIndicator(
                      quotaUsage: snapshot.data ?? provider.currentQuota,
                    );
                  },
                );
              },
            ),
            // Messages List
            Expanded(
              child: Consumer<SuperChatProvider>(
                builder: (context, provider, child) {
                  return _buildMessagesList(provider.state);
                },
              ),
            ),
            // Input Bar
            Consumer<SuperChatProvider>(
              builder: (context, provider, child) {
                final isProcessing = provider.state is SuperChatProcessing;
                final hasTextQuota =
                    provider.currentQuota?.hasTextQuota ?? true;
                final hasVoiceQuota =
                    provider.currentQuota?.hasVoiceQuota ?? true;

                return HybridInputBar(
                  onSendText: _handleSendText,
                  onSendImage: _handleSendImage,
                  onSendVoice: _handleSendVoice,
                  isProcessing: isProcessing,
                  canSendText: hasTextQuota,
                  canSendVoice: hasVoiceQuota,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1E3A8A),
            child: Icon(
              Icons.school,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Professor',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Always here to help',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<SuperChatProvider>(
          builder: (context, provider, child) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearConfirmation(provider);
                } else if (value == 'upgrade') {
                  _navigateToSubscription();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'upgrade',
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, size: 20),
                      SizedBox(width: 12),
                      Text('Upgrade Plan'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList(SuperChatState state) {
    if (state is SuperChatInitial) {
      return _buildEmptyState();
    }

    final messages = state is SuperChatLoaded
        ? state.messages
        : state is SuperChatProcessing
            ? state.messages
            : state is SuperChatError
                ? state.messages
                : state is SuperChatQuotaExceeded
                    ? state.messages
                    : <dynamic>[];

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (state is SuperChatProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          return MessageBubble(message: messages[index]);
        } else {
          // Processing indicator
          return _buildProcessingIndicator(
            (state as SuperChatProcessing).processingMessage,
          );
        }
      },
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Super Chat!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask questions with text, photos, or voice.\nYour AI Professor is ready to help!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureChip(Icons.camera_alt, 'Scan homework'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.edit, 'Ask anything'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.mic, 'Voice questions'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF1E3A8A),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(SuperChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearMessages();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription() {
    // Navigate to subscription screen
    // Navigator.pushNamed(context, '/subscription');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription screen - Coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
