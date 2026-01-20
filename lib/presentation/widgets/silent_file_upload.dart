// Silent File Upload - Elegant Progress Indicator
import 'package:flutter/material.dart';
import 'dart:io';

class SilentFileUpload extends StatefulWidget {
  final String fileName;
  final int fileSize;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const SilentFileUpload({
    super.key,
    required this.fileName,
    required this.fileSize,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<SilentFileUpload> createState() => _SilentFileUploadState();
}

class _SilentFileUploadState extends State<SilentFileUpload>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Smooth 2s upload simulation
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Auto-start upload
    _progressController.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF7), // Paper white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0A192F).withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // File info
              Row(
                children: [
                  Icon(
                    _getFileIcon(),
                    size: 20,
                    color: const Color(0xFF0A192F).withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A192F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(widget.fileSize),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF0A192F).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_progressAnimation.value < 1.0)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: const Color(0xFF0A192F).withOpacity(0.4),
                      ),
                      onPressed: widget.onCancel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Silent progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF0A192F).withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF0A192F).withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Status text (subtle)
              Text(
                _progressAnimation.value < 1.0
                    ? 'Uploading... ${(_progressAnimation.value * 100).toInt()}%'
                    : 'Upload complete',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF0A192F).withOpacity(0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getFileIcon() {
    final ext = widget.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
        return Icons.image_outlined;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
