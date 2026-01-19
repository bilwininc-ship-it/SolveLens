// Premium Elite Super Chat Screen - with Mode Selection & Conversation Management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/di/service_locator.dart';
import '../../../services/ai/ai_service.dart';
import '../../../services/voice/voice_service.dart';
import '../../../services/quota/quota_service.dart';
import '../../../services/conversation/conversation_service.dart';
import '../../../services/notes/notes_service.dart';
import '../../../data/models/conversation_model.dart';
import '../../providers/super_chat_provider.dart';
import '../../providers/super_chat_state.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chat/quota_indicator.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/hybrid_input_bar.dart';
import '../../theme/app_theme.dart';
import 'conversations_list_screen.dart';

class SuperChatScreen extends StatefulWidget {
  final String? conversationId;
  final ChatMode? initialMode;

  const SuperChatScreen({
    super.key,
    this.conversationId,
    this.initialMode,
  });

  @override
  State<SuperChatScreen> createState() => _SuperChatScreenState();
}

class _SuperChatScreenState extends State<SuperChatScreen> {
  late SuperChatProvider _chatProvider;
  final ScrollController _scrollController = ScrollController();
  final ConversationService _conversationService = getIt<ConversationService>();
  final NotesService _notesService = getIt<NotesService>();
  
  ChatMode _selectedMode = ChatMode.textToText;
  String? _currentConversationId;
  ConversationModel? _currentConversation;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? ChatMode.textToText;
    _currentConversationId = widget.conversationId;
    _initializeChatProvider();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    if (_currentConversationId == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final conversation = await _conversationService.getConversation(
        userId: user.uid,
        conversationId: _currentConversationId!,
      );
      
      if (conversation != null) {
        setState(() {
          _currentConversation = conversation;
          _selectedMode = conversation.mode;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversation: $e');
    }
  }

  void _initializeChatProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _chatProvider = SuperChatProvider(
      aiService: getIt<AIService>(),
      voiceService: getIt<VoiceService>(),
      quotaService: getIt<QuotaService>(),
      userId: user.uid,
      userProvider: userProvider,
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

  Future<void> _handleSendText(String text) async {
    await _chatProvider.sendTextMessage(text, mode: _selectedMode);
    _scrollToBottom();
    await _saveMessageToConversation(text, true);
  }

  Future<void> _handleSendImage(file, caption) async {
    await _chatProvider.sendImageMessage(file, text: caption);
    _scrollToBottom();
    await _saveMessageToConversation(caption ?? 'Image message', true);
  }

  Future<void> _handleSendVoice(String transcribedText, double durationMinutes) async {
    await _chatProvider.sendVoiceMessage(transcribedText, durationMinutes, mode: _selectedMode);
    _scrollToBottom();
    await _saveMessageToConversation(transcribedText, true);
  }

  Future<void> _handleSendPDF(file, fileName, fileSize) async {
    await _chatProvider.sendPDFMessage(file, fileName, fileSize);
    _scrollToBottom();
    await _saveMessageToConversation('PDF: $fileName', true);
  }

  Future<void> _saveMessageToConversation(String message, bool isUser) async {
    if (_currentConversationId == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _conversationService.updateConversation(
        userId: user.uid,
        conversationId: _currentConversationId!,
        lastMessage: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      );
    } catch (e) {
      debugPrint('Error saving message to conversation: $e');
    }
  }

  Future<void> _saveMessageAsNote(dynamic message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _notesService.saveNote(
        userId: user.uid,
        imageUrl: '',
        solutionText: message.text,
        question: message.isUser ? message.text : 'Professor Response',
        subject: 'Chat Note',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Not olarak kaydedildi'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _onModeChanged(ChatMode? newMode) {
    if (newMode != null && newMode != _selectedMode) {
      setState(() {
        _selectedMode = newMode;
      });

      // Update conversation mode if conversation exists
      if (_currentConversationId != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _conversationService.updateConversation(
            userId: user.uid,
            conversationId: _currentConversationId!,
            mode: newMode,
          );
        }
      }

      // Show mode change notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(newMode.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text('Mod değiştirildi: ${newMode.displayName}'),
            ],
          ),
          backgroundColor: AppTheme.primaryNavy,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SuperChatProvider>.value(
      value: _chatProvider,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrey,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Mode Selector
            _buildModeSelector(),
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
                  onSendPDF: _handleSendPDF,
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
              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppTheme.primaryNavy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentConversation?.title ?? 'AI Professor',
                  style: const TextStyle(
                    color: AppTheme.primaryNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedMode.displayName,
                  style: const TextStyle(
                    color: AppTheme.mediumGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Conversations List Button
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppTheme.primaryNavy,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversationsListScreen(),
              ),
            );
          },
          tooltip: 'Sohbetlerim',
        ),
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
                } else if (value == 'rename') {
                  _showRenameDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: AppTheme.primaryNavy,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Yeniden Adlandır',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        'Sohbeti Temizle',
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
                        'Premium Ol',
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

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.mediumGrey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.swap_horiz_rounded,
            color: AppTheme.primaryNavy,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Mod:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ChatMode>(
                  value: _selectedMode,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryNavy,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryNavy,
                  ),
                  dropdownColor: AppTheme.cleanWhite,
                  borderRadius: BorderRadius.circular(12),
                  onChanged: _onModeChanged,
                  items: ChatMode.values.map((mode) {
                    return DropdownMenuItem<ChatMode>(
                      value: mode,
                      child: Row(
                        children: [
                          Text(
                            mode.icon,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(mode.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
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
          return _buildMessageWithActions(messages[index]);
        } else {
          return _buildProcessingIndicator(
            (state as SuperChatProcessing).processingMessage,
          );
        }
      },
    );
  }

  Widget _buildMessageWithActions(dynamic message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MessageBubble(message: message),
        ),
        // Save as note button
        if (!message.isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              onPressed: () => _saveMessageAsNote(message),
              icon: const Icon(
                Icons.bookmark_add_outlined,
                color: AppTheme.primaryNavy,
                size: 20,
              ),
              tooltip: 'Not olarak kaydet',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.cleanWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
      ],
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
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
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
              'Süper Sohbete Hoş Geldiniz!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Metin, fotoğraf, PDF veya ses ile soru sorun.\nAI Profesörünüz size yardım etmeye hazır!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mediumGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureChip(Icons.camera_alt_rounded, 'Ödev tarama'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.picture_as_pdf, 'PDF yükleme'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.edit_rounded, 'Her şeyi sorun'),
            const SizedBox(height: 12),
            _buildFeatureChip(Icons.mic_rounded, 'Sesli sorular'),
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
              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
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

  void _showRenameDialog() async {
    if (_currentConversationId == null) return;
    
    final controller = TextEditingController(
      text: _currentConversation?.title ?? '',
    );

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cleanWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Sohbeti Yeniden Adlandır',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Sohbet başlığı',
            filled: true,
            fillColor: AppTheme.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGrey,
            ),
            child: const Text(
              'İptal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
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
              'Kaydet',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _conversationService.updateConversation(
          userId: user.uid,
          conversationId: _currentConversationId!,
          title: newTitle,
        );
        await _loadConversation();
      }
    }
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
          'Sohbeti Temizle',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tüm mesajlar silinecek. Bu işlem geri alınamaz. Emin misiniz?',
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
              'İptal',
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
              'Temizle',
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
        content: const Text('Abonelik ekranı - Yakında'),
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
