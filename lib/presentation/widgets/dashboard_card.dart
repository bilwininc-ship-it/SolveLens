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
        borderRadius: BorderRadius.circular(20), // Reduced from 24px to 20px
        boxShadow: [
          // Airy Shadow - Ultra-subtle and premium
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 12,
            color: const Color(0x0D000000), // Very subtle shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced from 24 to 16 (~30% reduction)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Premium Icon Container
                    Container(
                      padding: const EdgeInsets.all(10), // Reduced from 14 to 10
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryNavy, // Navy Blue icons
                        size: 20, // Reduced from 26 to 20 (~30% reduction)
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: AppTheme.cleanWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14), // Reduced from 20 to 14
                
                // Title - Navy Blue, Reduced size
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.primaryNavy, // #1E3A8A
                    fontSize: 15, // Reduced from 17 to 15
                    fontWeight: FontWeight.w600, // Semi-Bold
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6), // Reduced from 10 to 6
                
                // Subtitle - Slate Grey, Reduced size
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.mediumGrey, // #64748B
                    fontSize: 11, // Reduced from 12 to 11
                    fontWeight: FontWeight.w400, // Regular
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12), // Reduced from 20 to 12
                
                // Arrow Icon - Subtle
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryNavy.withOpacity(0.5),
                    size: 18, // Reduced from 22 to 18
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
