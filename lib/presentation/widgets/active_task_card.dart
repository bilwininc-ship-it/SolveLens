// Active Task Card - Dark Gradient Hero Component
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActiveTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String lastUpdate;
  final double progress;
  final VoidCallback onTap;

  const ActiveTaskCard({
    super.key,
    this.title = 'SolveLens AI: Physics Analysis',
    this.description = 'Quantum mechanics problem solving with real-time step-by-step analysis. Currently processing advanced wave function calculations and eigenvalue problems.',
    this.status = '12 queries today',
    this.lastUpdate = 'Last updated 23 min ago',
    this.progress = 0.68,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryNavy, // #0A192F
              AppTheme.navyGradientEnd, // #1A2F4F
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 20),
              blurRadius: 60,
              color: AppTheme.primaryNavy.withOpacity(0.3),
            ),
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 16,
              color: AppTheme.primaryNavy.withOpacity(0.2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      AppTheme.cyanNeon.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppTheme.cyanNeon,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ACTIVE PROJECT',
                                  style: TextStyle(
                                    color: AppTheme.cyanNeon,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            // Status Row
                            Row(
                              children: [
                                // Pulse dot
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyanNeon,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.cyanNeon.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    color: AppTheme.cyanNeon,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 1,
                                  height: 16,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  lastUpdate,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.cyanNeon.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.cyanNeon.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.cyanNeon,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cyanNeon,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cyanNeon.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
