// AI Solution Screen - Premium Academic Design with Socratic Mentor Response
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../../providers/solution_provider.dart';
import '../../providers/solution_state.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notes/notes_service.dart';
import '../../../core/di/service_locator.dart';

class AISolutionScreen extends StatefulWidget {
  final File imageFile;

  const AISolutionScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<AISolutionScreen> createState() => _AISolutionScreenState();
}

class _AISolutionScreenState extends State<AISolutionScreen> with TickerProviderStateMixin {
  late SolutionProvider _solutionProvider;
  late AnimationController _starAnimationController;
  late NotesService _notesService;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _solutionProvider = Provider.of<SolutionProvider>(context, listen: false);
    _notesService = getIt<NotesService>();
    _starAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _analyzQuestion();
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    super.dispose();
  }
  Future<void> _analyzQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _solutionProvider.analyzeQuestion(
        imageFile: widget.imageFile,
        userId: user.uid,
      );
    }
  }

  /// Saves the current solution as a note
  Future<void> _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final question = _solutionProvider.currentQuestion;
    if (question == null) return;

    try {
      // Check if already saved
      final exists = await _notesService.noteExists(
        userId: user.uid,
        question: question.question,
      );

      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📝 This note is already saved!'),
              backgroundColor: Color(0xFFD4AF37),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Save the note
      await _notesService.saveNote(
        userId: user.uid,
        imageUrl: question.imageUrl,
        solutionText: question.answer,
        question: question.question,
        subject: question.subject,
      );

      // Play animation
      _starAnimationController.forward().then((_) {
        _starAnimationController.reverse();
      });

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '⭐ Note saved successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD4AF37),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Clean light grey background
      appBar: _buildAppBar(context),
      body: Consumer<SolutionProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider.state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'AI Mentor Solution',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Save Note Button with animation
        Consumer<SolutionProvider>(
          builder: (context, provider, child) {
            final canSave = provider.state is SolutionSuccess;
            return AnimatedBuilder(
              animation: _starAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_starAnimationController.value * 0.3),
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? Icons.star : Icons.star_border,
                      color: const Color(0xFFD4AF37),
                    ),
                    tooltip: _isSaved ? 'Saved' : 'Save Note',
                    onPressed: canSave ? _saveNote : null,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(SolutionState state) {
    if (state is SolutionScanning) {
      return _buildLoadingView('Scanning your question...', 0.3);
    } else if (state is SolutionAnalyzing) {
      return _buildLoadingView('AI Mentor is thinking...', state.progress);
    } else if (state is SolutionSuccess) {
      return _buildSolutionView(state.question.answer);
    } else if (state is SolutionError) {
      return _buildErrorView(state.message);
    } else {
      return _buildLoadingView('Preparing...', 0.0);
    }
  }

  Widget _buildLoadingView(String message, double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4AF37),
                  ),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              const Icon(
                Icons.school,
                size: 40,
                color: Color(0xFFD4AF37),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (progress > 0) ...[
            const SizedBox(height: 12),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionView(String solution) {
    return Stack(
      children: [
        // Main Content
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 100, // Space for sticky interaction bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header
              _buildPremiumHeader(),
              const SizedBox(height: 24),

              // Solution Content with LaTeX and Markdown
              _buildSolutionContent(solution),
            ],
          ),
        ),

        // Sticky Interaction Bar at Bottom
        _buildInteractionBar(),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFE5C158),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.school,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Socratic Mentor Solution',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Learning through understanding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionContent(String solution) {
    // Parse the solution to separate LaTeX blocks from regular text
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMixedContent(solution),
    );
  }

  Widget _buildMixedContent(String content) {
    // Split content by LaTeX display blocks \[ ... \]
    final parts = <Widget>[];
    final displayLatexPattern = RegExp(r'\\\[(.*?)\\\]', dotAll: true);
    
    int lastIndex = 0;
    
    // Find all display LaTeX blocks
    for (final match in displayLatexPattern.allMatches(content)) {
      // Add text before LaTeX
      if (match.start > lastIndex) {
        final textBefore = content.substring(lastIndex, match.start);
        parts.add(_buildMarkdownText(textBefore));
        parts.add(const SizedBox(height: 16));
      }
      
      // Add LaTeX block in a special container
      final latexCode = match.group(1)?.trim() ?? '';
      parts.add(_buildLatexBlock(latexCode));
      parts.add(const SizedBox(height: 16));
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < content.length) {
      final remainingText = content.substring(lastIndex);
      parts.add(_buildMarkdownText(remainingText));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  Widget _buildMarkdownText(String text) {
    // Process inline LaTeX within markdown
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF1A1A1A),
        ),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        h3: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Color(0xFF1A1A1A),
        ),
        listBullet: const TextStyle(
          fontSize: 16,
          color: Color(0xFFD4AF37),
        ),
        code: TextStyle(
          fontSize: 14,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFF1A1A1A),
        ),
        blockquote: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildLatexBlock(String latexCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Soft gold background for math
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TeXView(
        child: TeXViewDocument(
          '\$\$ $latexCode \$\$',
          style: TeXViewStyle(
            contentColor: const Color(0xFF1A1A1A),
            backgroundColor: const Color(0xFFFFF8E1),
            textAlign: TeXViewTextAlign.center,
            fontStyle: TeXViewFontStyle(
              fontSize: 18,
            ),
          ),
        ),
        style: TeXViewStyle(
          backgroundColor: const Color(0xFFFFF8E1),
          padding: TeXViewPadding.all(0),
          margin: TeXViewMargin.all(0),
        ),
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Listen Button
              _buildInteractionButton(
                icon: Icons.volume_up,
                label: 'Listen',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔊 Listen feature - Coming in Sprint 2'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Voice Ask Button
              _buildInteractionButton(
                icon: Icons.mic,
                label: 'Voice Ask',
                color: const Color(0xFF2196F3),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎤 Voice Ask feature - Coming in Sprint 2'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Message Button
              _buildInteractionButton(
                icon: Icons.message,
                label: 'Message',
                color: const Color(0xFFD4AF37),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✍️ Message feature - Coming in Sprint 2'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
