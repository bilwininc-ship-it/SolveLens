// Academic Coach Desk - Layered Research Interface (Z0-Z4 Architecture)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/ai/ai_service.dart';
import '../../../services/voice/voice_service.dart';
import '../../../services/quota/quota_service.dart';
import '../../../services/conversation/conversation_service.dart';
import '../../../services/notes/notes_service.dart';
import '../../../data/models/conversation_model.dart';
import '../../providers/super_chat_provider.dart';
import '../../providers/super_chat_state.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/academic_skeleton.dart';
import '../../widgets/credit_pulse_counter.dart';
import '../../widgets/silent_file_upload.dart';
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

class _SuperChatScreenState extends State<SuperChatScreen> with TickerProviderStateMixin {
  // Core Services
  late SuperChatProvider _chatProvider;
  final ConversationService _conversationService = getIt<ConversationService>();
  final NotesService _notesService = getIt<NotesService>();
  
  // UI Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  
  // State Variables
  ChatMode _selectedMode = ChatMode.textToText;
  String? _currentConversationId;
  
  // Z3 - Resource Dock State
  bool _isResourceDockOpen = false;
  final List<Map<String, dynamic>> _uploadingFiles = []; // Track uploading files
  
  // Z4 - Discipline Layer State
  bool _isDisciplineLocked = false;
  Timer? _disciplineTimer;
  int _remainingFocusSeconds = 0;
  
  
  // Typography Sharpness (Cognitive Depth)
  double _contentSharpness = 1.0; // 1.0 = normal, 2.0 = maximum sharpness
  Timer? _readingTimer;
  int _readingTimeSeconds = 0;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? ChatMode.textToText;
    _currentConversationId = widget.conversationId;
    _initializeChatProvider();
    _startReadingTimer();
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

  void _startReadingTimer() {
    _readingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _readingTimeSeconds += 10;
        // Gradually increase sharpness based on reading time (max at 5 minutes)
        _contentSharpness = 1.0 + (_readingTimeSeconds / 300).clamp(0.0, 1.0);
      });
    });
  }

  void _triggerDisciplineLock() {
    setState(() {
      _isDisciplineLocked = true;
      _remainingFocusSeconds = 180; // 3 minutes
    });

    _disciplineTimer?.cancel();
    _disciplineTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingFocusSeconds--;
        if (_remainingFocusSeconds <= 0) {
          _isDisciplineLocked = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _chatProvider.dispose();
    _disciplineTimer?.cancel();
    _readingTimer?.cancel();
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
                Text(AppStrings.savedToNotes),
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
            content: Text('${AppStrings.errorPrefix}$e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SuperChatProvider>.value(
      value: _chatProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F7), // Ivory Research Surface
        body: Stack(
          children: [
            // Z0 - Research Surface (Main Content Area)
            _buildResearchSurface(),
            
            // Z2 - Edge UI (Right Side Vertical Dock + Credit Counter)
            _buildEdgeUI(),
            
            // Z3 - Floating Resource Dock (Bottom-Right Expandable Panel)
            _buildResourceDock(),
            
            // Z1 - Input Control (Bottom Sliding Input)
            _buildInputControl(),
            
            // Z4 - Discipline Layer (Cognitive Lock Overlay)
            if (_isDisciplineLocked) _buildDisciplineLayer(),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Z0 - RESEARCH SURFACE
  // ========================================
  Widget _buildResearchSurface() {
    return Consumer<SuperChatProvider>(
      builder: (context, provider, child) {
        final messages = _getMessagesFromState(provider.state);
        final isProcessing = provider.state is SuperChatProcessing;
        final processingMessage = isProcessing 
            ? (provider.state as SuperChatProcessing).processingMessage 
            : '';
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F7), // Ivory
            // Subtle paper texture effect
            image: DecorationImage(
              image: const AssetImage('assets/images/paper_texture.png'),
              fit: BoxFit.cover,
              opacity: 0.03,
              onError: (exception, stackTrace) {
                // Gracefully handle missing texture
              },
            ),
          ),
          child: messages.isEmpty && !isProcessing
              ? _buildEmptyResearchState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: 80, // Space for credit counter
                    left: 32,
                    right: 100, // Space for edge UI
                    bottom: 120, // Space for input
                  ),
                  itemCount: messages.length + (isProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < messages.length) {
                      return _buildRichTextMessage(messages[index]);
                    } else {
                      // Show Academic Skeleton when processing
                      return AcademicSkeleton(message: processingMessage);
                    }
                  },
                ),
        );
      },
    );
  }

  List<dynamic> _getMessagesFromState(SuperChatState state) {
    if (state is SuperChatLoaded) return state.messages;
    if (state is SuperChatProcessing) return state.messages;
    if (state is SuperChatError) return state.messages;
    if (state is SuperChatQuotaExceeded) return state.messages;
    return [];
  }

  Widget _buildEmptyResearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: const Color(0xFF0A192F).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.academicCoachDesk,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A192F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.disciplinedSpaceSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF0A192F).withOpacity(0.6),
                height: 1.6,
                fontFamily: 'Serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichTextMessage(dynamic message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author label
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF00F0FF) : const Color(0xFF0A192F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isUser ? AppStrings.youLabel : AppStrings.professorLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A192F).withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message content with dynamic sharpness
          AnimatedOpacity(
            opacity: _contentSharpness,
            duration: const Duration(milliseconds: 500),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: _determineContentFontSize(message.text),
                fontWeight: _determineContentWeight(message.text),
                fontFamily: _determineContentFont(message.text),
                color: const Color(0xFF0A192F),
                height: 1.7,
                letterSpacing: _contentSharpness > 1.5 ? -0.3 : 0,
              ),
            ),
          ),
          // Bookmark action for professor responses
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () => _saveMessageAsNote(message),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: const Color(0xFF0A192F).withOpacity(0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.saveToNotes,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF0A192F).withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _determineContentFontSize(String text) {
    // Formulas and mathematical content: larger
    if (text.contains(RegExp(r'[\d+\-*/=]|\\[[(]'))) {
      return 18.0;
    }
    // Regular text
    return 16.0;
  }

  FontWeight _determineContentWeight(String text) {
    // Formulas: sharper/bolder
    if (text.contains(RegExp(r'[\d+\-*/=]|\\[[(]'))) {
      return FontWeight.w600;
    }
    return FontWeight.w400;
  }

  String _determineContentFont(String text) {
    // Formulas: Sans-serif for clarity
    if (text.contains(RegExp(r'[\d+\-*/=]|\\[[(]'))) {
      return 'Sans-serif';
    }
    // Philosophical/text content: Serif for reading comfort
    return 'Serif';
  }

  // ========================================
  // Z2 - EDGE UI (Right Side Dock + Credit Counter)
  // ========================================
  Widget _buildEdgeUI() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Column(
        children: [
          // Credit Counter (Top Right)
          _buildCreditCounter(),
          
          const SizedBox(height: 40),
          
          // Vertical Icon Dock
          Container(
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                _buildEdgeButton(
                  icon: Icons.dashboard_outlined,
                  label: AppStrings.dashboard,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildEdgeButton(
                  icon: Icons.history_outlined,
                  label: AppStrings.history,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConversationsListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildEdgeButton(
                  icon: Icons.person_outline,
                  label: AppStrings.profile,
                  onTap: () {
                    // Navigate to profile
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCounter() {
    return Consumer<SuperChatProvider>(
      builder: (context, provider, child) {
        return StreamBuilder(
          stream: provider.streamQuota(),
          builder: (context, snapshot) {
            final quota = snapshot.data ?? provider.currentQuota;
            final used = quota?.textMessagesUsed ?? 0;
            final total = quota?.textMessagesLimit ?? 15;
            
            return Container(
              margin: const EdgeInsets.only(top: 48, right: 16),
              child: CreditPulseCounter(
                used: used,
                total: total,
                onTap: () => _showCreditDetails(quota),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEdgeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: const Color(0xFF0A192F),
          ),
        ),
      ),
    );
  }

  void _showCreditDetails(dynamic quota) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.creditUsage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),
            _buildUsageRow(AppStrings.textMessages, quota?.textMessagesUsed ?? 0, quota?.textMessagesLimit ?? 15),
            const SizedBox(height: 12),
            _buildUsageRow(AppStrings.voiceMinutes, quota?.voiceMinutesUsed?.toInt() ?? 0, quota?.voiceMinutesLimit?.toInt() ?? 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(String label, int used, int total) {
    final percentage = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0A192F).withOpacity(0.7),
              ),
            ),
            Text(
              '$used / $total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A192F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: const Color(0xFF0A192F).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
          ),
        ),
      ],
    );
  }

  // ========================================
  // Z3 - FLOATING RESOURCE DOCK
  // ========================================
  Widget _buildResourceDock() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 0,
      bottom: 100,
      width: _isResourceDockOpen ? MediaQuery.of(context).size.width * 0.25 : 56,
      height: _isResourceDockOpen ? 400 : 56,
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _isResourceDockOpen ? _buildExpandedResourcePanel() : _buildResourceDockButton(),
      ),
    );
  }

  Widget _buildResourceDockButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isResourceDockOpen = true;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.attach_file_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedResourcePanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF0A192F).withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 20,
                color: Color(0xFF0A192F),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppStrings.resourceDock,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A192F),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _isResourceDockOpen = false;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Upload Buttons
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildResourceButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: AppStrings.uploadPDF,
                  onTap: _handlePDFUpload,
                ),
                const SizedBox(height: 12),
                _buildResourceButton(
                  icon: Icons.image_outlined,
                  label: AppStrings.uploadImage,
                  onTap: _handleImageUpload,
                ),
                const SizedBox(height: 20),
                
                // Uploading files list
                if (_uploadingFiles.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  ..._uploadingFiles.map((fileData) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SilentFileUpload(
                        fileName: fileData['name'],
                        fileSize: fileData['size'],
                        onComplete: () {
                          setState(() {
                            _uploadingFiles.remove(fileData);
                          });
                        },
                        onCancel: () {
                          setState(() {
                            _uploadingFiles.remove(fileData);
                          });
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePDFUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();

        setState(() {
          _uploadingFiles.add({
            'name': fileName,
            'size': fileSize,
            'file': file,
          });
        });

        // Send to chat provider
        await _handleSendPDF(file, fileName, fileSize);
      }
    } catch (e) {
      debugPrint('PDF upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.failedToUploadPDF}$e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleImageUpload() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileName = image.name;
        final fileSize = await file.length();

        setState(() {
          _uploadingFiles.add({
            'name': fileName,
            'size': fileSize,
            'file': file,
          });
        });

        // Send to chat provider
        await _handleSendImage(file, null);
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.failedToUploadImage}$e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildResourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0A192F).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF0A192F),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A192F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Z1 - INPUT CONTROL (Bottom Sliding)
  // ========================================
  Widget _buildInputControl() {
    return Consumer<SuperChatProvider>(
      builder: (context, provider, child) {
        final isProcessing = provider.state is SuperChatProcessing;
        
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 0,
          right: 80, // Space for edge UI
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_isDisciplineLocked && !isProcessing,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF0A192F),
                    ),
                    decoration: InputDecoration(
                      hintText: _isDisciplineLocked 
                          ? AppStrings.inputLockedFocusMode
                          : AppStrings.askYourQuestion,
                      hintStyle: TextStyle(
                        color: const Color(0xFF0A192F).withOpacity(0.4),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                if (isProcessing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A192F)),
                    ),
                  )
                else
                  IconButton(
                    onPressed: _isDisciplineLocked ? null : _handleSendMessage,
                    icon: Icon(
                      Icons.send_rounded,
                      color: _isDisciplineLocked
                          ? const Color(0xFF0A192F).withOpacity(0.2)
                          : const Color(0xFF00F0FF),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _isDisciplineLocked
                          ? const Color(0xFF0A192F).withOpacity(0.05)
                          : const Color(0xFF00F0FF).withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    _inputController.clear();
    await _handleSendText(text);
    
    // Trigger discipline lock for complex queries (simpler loop detection)
    if (text.length < 20 || text.split(' ').length < 4) {
      _triggerDisciplineLock();
    }
  }

  // ========================================
  // Z4 - DISCIPLINE LAYER (Cognitive Lock)
  // ========================================
  Widget _buildDisciplineLayer() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _isDisciplineLocked ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: const Color(0xFF0A192F).withOpacity(0.85),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 48),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 64,
                    color: Color(0xFF0A192F),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.deepFocusRitual,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.focusReflectionMessage}${_formatFocusTime(_remainingFocusSeconds)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF0A192F).withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _remainingFocusSeconds / 180,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF0A192F).withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatFocusTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}
