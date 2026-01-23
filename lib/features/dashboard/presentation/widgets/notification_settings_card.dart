import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/app_colors.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../core/utils/logger.dart';

/// Elite Notification Settings Card
/// Features:
/// - Toggle switch for notifications
/// - Real-time sync with Firestore
/// - Navy & Cyan Neon design
/// - Web platform guard
class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  /// Load current notification settings from Firestore
  Future<void> _loadNotificationSettings() async {
    if (kIsWeb) {
      setState(() {
        _isLoading = false;
        _notificationsEnabled = false;
      });
      return;
    }

    try {
      final enabled = await NotificationService.getNotificationSettings();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Failed to load notification settings', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Toggle notification settings
  Future<void> _toggleNotifications(bool value) async {
    if (kIsWeb) {
      _showWebNotSupportedMessage();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationService.toggleNotifications(value);
      
      if (mounted) {
        setState(() {
          _notificationsEnabled = value;
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Notifications enabled successfully'
                  : 'Notifications disabled successfully',
              style: const TextStyle(color: AppColors.navy),
            ),
            backgroundColor: AppColors.cyanNeon,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Logger.error('Failed to toggle notifications', error: e);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to update notification settings',
              style: TextStyle(color: AppColors.ivory),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// Show web not supported message
  void _showWebNotSupportedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Push notifications are not supported on web browsers',
          style: TextStyle(color: AppColors.ivory),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyanNeon.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cyanNeon.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: AppColors.cyanNeon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receive Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.ivory,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kIsWeb
                          ? 'Not supported on web'
                          : 'Get updates about new features and announcements',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                    ),
                  ],
                ),
              ),

              // Toggle Switch
              if (!kIsWeb)
                _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.cyanNeon,
                          ),
                        ),
                      )
                    : Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: AppColors.cyanNeon,
                        activeTrackColor: AppColors.cyanNeon.withOpacity(0.3),
                        inactiveThumbColor: AppColors.grey,
                        inactiveTrackColor: AppColors.greyDark.withOpacity(0.3),
                        splashRadius: 20,
                      )
              else
                Icon(
                  Icons.block_rounded,
                  color: AppColors.grey,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
