// Premium PDF Card Widget - High-End Document Display
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PdfCardWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback? onTap;

  const PdfCardWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cleanWhite, // Pure White background
          borderRadius: BorderRadius.circular(24), // 24px rounded corners
          boxShadow: [
            // Airy Shadow - subtle, light grey
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side: Navy Blue PDF Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: AppTheme.primaryNavy, // Navy Blue (#1E3A8A)
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Middle: File Name and File Size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File Name - Bold, Navy
                  Text(
                    fileName,
                    style: const TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // File Size - Slate Grey
                  Text(
                    fileSize,
                    style: const TextStyle(
                      color: AppTheme.mediumGrey, // Slate Grey
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right side: "Document" Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.brightBlue.withValues(alpha: 0.1), // Light blue background
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Document',
                style: TextStyle(
                  color: AppTheme.primaryNavy, // Navy text
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
