// Message Bubble Widget - Supports user and professor messages with text, images, and audio
import 'package:flutter/material.dart';
import 'pdf_card_widget.dart';
import '../../../data/models/chat_message_model.dart';
import 'audio_player_widget.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: message.isUser ? _buildUserBubble() : _buildProfessorBubble(),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Navy blue for user
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF Card if present
          if (message.hasPDF && message.pdfFileName != null && message.pdfFileSize != null) ...[
            PdfCardWidget(
              fileName: message.pdfFileName!,
              fileSize: message.pdfFileSize!,
              onTap: () {
                // TODO: Open PDF viewer
              },
            ),
            if (message.text.isNotEmpty) const SizedBox(height: 8),
          ],
          // Image if present
          if (message.hasImage && message.imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                message.imageFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (message.text.isNotEmpty) const SizedBox(height: 8),
          ],
          // Text
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 4),
          // Timestamp
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessorBubble() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Professor label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school,
                      size: 12,
                      color: Color(0xFF1E3A8A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Professor',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Text
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          // Audio player if present
          if (message.hasAudio)
            AudioPlayerWidget(
              audioUrl: message.audioUrl,
            ),
          const SizedBox(height: 4),
          // Timestamp
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
