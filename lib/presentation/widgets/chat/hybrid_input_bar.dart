// Hybrid Input Bar - Camera + Text Field + Microphone
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HybridInputBar extends StatefulWidget {
  final Function(String text)? onSendText;
  final Function(File image, String? caption)? onSendImage;
  final Function(String transcribedText, double durationMinutes)? onSendVoice;
  final bool isProcessing;
  final bool canSendText;
  final bool canSendVoice;

  const HybridInputBar({
    super.key,
    this.onSendText,
    this.onSendImage,
    this.onSendVoice,
    this.isProcessing = false,
    this.canSendText = true,
    this.canSendVoice = true,
  });

  @override
  State<HybridInputBar> createState() => _HybridInputBarState();
}

class _HybridInputBarState extends State<HybridInputBar> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecording = false;
  bool _hasText = false;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCamera() async {
    try {
      // Show bottom sheet to choose camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  color: const Color(0xFF1E3A8A),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  color: const Color(0xFF1E3A8A),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );

        if (image != null) {
          final caption = _textController.text.trim();
          _textController.clear();
          widget.onSendImage?.call(File(image.path), caption.isEmpty ? null : caption);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !widget.isProcessing) {
      widget.onSendText?.call(text);
      _textController.clear();
    }
  }

  Future<void> _handleMicrophone() async {
    if (!widget.canSendVoice) {
      _showQuotaExceededMessage('voice');
      return;
    }

    if (_isRecording) {
      // Stop recording and process audio
      await _stopRecording();
    } else {
      // Start recording
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordingStartTime = DateTime.now();
    });

    // Show recording indicator with cancel button
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mic, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Recording... Tap mic to stop'),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: _cancelRecording,
                tooltip: 'Cancel',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          duration: const Duration(days: 1), // Will be dismissed manually
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    // Dismiss the recording SnackBar immediately
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    setState(() {
      _isRecording = false;
    });

    if (_recordingStartTime != null) {
      final duration = DateTime.now().difference(_recordingStartTime!);
      final minutes = duration.inSeconds / 60.0;
      
      // In a real implementation, you'd get the transcribed text from speech-to-text
      // For now, we'll use a placeholder
      final transcribedText = 'Voice message transcribed';
      
      widget.onSendVoice?.call(transcribedText, minutes);
      _recordingStartTime = null;
    }
  }

  void _cancelRecording() {
    // Dismiss the recording SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    setState(() {
      _isRecording = false;
      _recordingStartTime = null;
    });

    // Show cancellation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Recording cancelled'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQuotaExceededMessage(String quotaType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quotaType == 'text'
              ? '💬 Text message quota exceeded. Upgrade to continue!'
              : '🎙️ Voice quota exceeded. Upgrade to continue!',
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Upgrade',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to subscription screen
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Camera/Photo Button
            IconButton(
              onPressed: widget.isProcessing ? null : _handleCamera,
              icon: Icon(
                Icons.add_photo_alternate,
                color: widget.isProcessing
                    ? Colors.grey.shade400
                    : const Color(0xFF1E3A8A),
              ),
              tooltip: 'Add photo',
            ),
            const SizedBox(width: 4),
            // Text Field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  enabled: !widget.isProcessing,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                  onSubmitted: (_) => _handleSendText(),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Send or Microphone Button
            _hasText
                ? IconButton(
                    onPressed: widget.isProcessing ? null : _handleSendText,
                    icon: Icon(
                      Icons.send,
                      color: widget.isProcessing
                          ? Colors.grey.shade400
                          : const Color(0xFF1E3A8A),
                    ),
                    tooltip: 'Send message',
                  )
                : IconButton(
                    onPressed: widget.isProcessing ? null : _handleMicrophone,
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: widget.isProcessing
                          ? Colors.grey.shade400
                          : _isRecording
                              ? Colors.red
                              : const Color(0xFF1E3A8A),
                    ),
                    tooltip: _isRecording ? 'Stop recording' : 'Voice message',
                  ),
          ],
        ),
      ),
    );
  }
}
