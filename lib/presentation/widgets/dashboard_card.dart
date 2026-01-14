// Premium Elite Dashboard Card - Ultra-Clean White Design
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String? badge;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AppTheme.primaryNavy,
    this.backgroundColor = AppTheme.cleanWhite,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24), // Premium 24px corners
        boxShadow: [
          // Airy Shadow - Ultra-subtle and premium
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000), // Very subtle shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24), // Generous padding for breathing room
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Premium Icon Container
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryNavy, // Navy Blue icons
                        size: 26, // Consistent 26px icon size
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: AppTheme.cleanWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20), // Generous spacing
                
                // Title - Navy Blue, 17pt, Semi-Bold
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.primaryNavy, // #1E3A8A
                    fontSize: 17,
                    fontWeight: FontWeight.w600, // Semi-Bold
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Subtitle - Slate Grey, 12pt, Regular
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.mediumGrey, // #64748B
                    fontSize: 12,
                    fontWeight: FontWeight.w400, // Regular
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // Arrow Icon - Subtle
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryNavy.withOpacity(0.5),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
