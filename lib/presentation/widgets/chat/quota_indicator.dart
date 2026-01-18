// Quota Indicator Widget - Shows text and voice usage at the top
import 'package:flutter/material.dart';
import '../../../services/quota/quota_service.dart';

class QuotaIndicator extends StatelessWidget {
  final QuotaUsage? quotaUsage;

  const QuotaIndicator({
    super.key,
    this.quotaUsage,
  });

  @override
  Widget build(BuildContext context) {
    if (quotaUsage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: _buildQuotaItem(
                icon: Icons.chat_bubble_outline,
                label: 'Text',
                current: quotaUsage!.textMessagesUsed,
                total: quotaUsage!.textMessagesLimit,
                progress: quotaUsage!.textProgress,
                color: _getProgressColor(quotaUsage!.textProgress),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuotaItem(
                icon: Icons.mic_outlined,
                label: 'Voice',
                current: quotaUsage!.voiceMinutesUsed.toInt(),
                total: quotaUsage!.voiceMinutesLimit.toInt(),
                progress: quotaUsage!.voiceProgress,
                color: _getProgressColor(quotaUsage!.voiceProgress),
                suffix: ' min',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaItem({
    required IconData icon,
    required String label,
    required num current,
    required num total,
    required double progress,
    required Color color,
    String suffix = '',
  }) {
    final remaining = total - current;
    final displayText = label == 'Text' 
        ? 'Bugün: $remaining hakkın kaldı'
        : 'Ses: ${remaining.toInt()} dakika';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (1 - progress).clamp(0.0, 1.0), // Invert to show remaining
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return const Color(0xFF4CAF50); // Green
    } else if (progress < 0.8) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFE53935); // Red
    }
  }
}
