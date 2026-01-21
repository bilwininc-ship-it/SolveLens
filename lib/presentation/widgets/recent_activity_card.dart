// Recent Activity Card - Scholarly Activity Item
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecentActivityCard extends StatelessWidget {
  final String query;
  final String tag;
  final String time;
  final VoidCallback? onTap;

  const RecentActivityCard({
    super.key,
    required this.query,
    required this.tag,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryNavy.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: AppTheme.primaryNavy,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query,
                        style: const TextStyle(
                          color: AppTheme.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanNeon.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.cyanNeon.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: AppTheme.primaryNavy,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            time,
                            style: TextStyle(
                              color: AppTheme.primaryNavy.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.primaryNavy.withOpacity(0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
