import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Maintenance Screen - Displayed when app is under maintenance
/// Prevents users from accessing the app during maintenance window
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 600 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maintenance Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cyanNeon, AppColors.info],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanNeon.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      size: 60,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Under Maintenance',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.ivory,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'SolveLens is currently undergoing scheduled maintenance to improve your experience.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Maintenance Details Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cyanNeon.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.schedule_rounded,
                          'Expected Duration',
                          '30-60 minutes',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Icons.info_outline_rounded,
                          'Status',
                          'In Progress',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Message
                  Text(
                    'Thank you for your patience.\nWe\'ll be back shortly!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyLight,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );  
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.cyanNeon,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.ivory,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
