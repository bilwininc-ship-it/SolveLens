// Premium Elite Super Chat Screen - Visual Harmony
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
import '../../theme/app_theme.dart';

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
        backgroundColor: AppTheme.lightGrey, // Premium light grey background
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
      backgroundColor: AppTheme.cleanWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.primaryNavy,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppTheme.primaryNavy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Professor',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Always here to help',
                style: TextStyle(
                  color: AppTheme.mediumGrey,
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
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppTheme.primaryNavy,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppTheme.primaryNavy,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Clear Chat',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'upgrade',
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 20,
                        color: AppTheme.primaryNavy,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Upgrade Plan',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.cleanWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 15,
                    color: const Color(0x0D000000),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 48,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Welcome to Super Chat!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask questions with text, photos, or voice.\nYour AI Professor is ready to help!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mediumGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureChip(Icons.camera_alt_rounded, 'Scan homework'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.edit_rounded, 'Ask anything'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.mic_rounded, 'Voice questions'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: const Color(0x08000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
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
                AppTheme.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGrey,
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
        backgroundColor: AppTheme.cleanWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Clear Chat',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
          style: TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGrey,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearMessages();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.cleanWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Subscription screen - Coming soon'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
