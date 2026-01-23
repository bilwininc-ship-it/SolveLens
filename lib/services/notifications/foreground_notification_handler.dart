import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/constants/app_colors.dart';

/// Foreground Notification Overlay
/// Displays elegant notification banner when app is open
class ForegroundNotificationHandler extends StatefulWidget {
  final Widget child;

  const ForegroundNotificationHandler({
    super.key,
    required this.child,
  });

  @override
  State<ForegroundNotificationHandler> createState() =>
      _ForegroundNotificationHandlerState();
}

class _ForegroundNotificationHandlerState
    extends State<ForegroundNotificationHandler> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Setup foreground message listener
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show overlay notification
    _showNotificationOverlay(
      title: notification.title ?? 'Notification',
      body: notification.body ?? '',
    );
  }

  /// Show notification overlay
  void _showNotificationOverlay({
    required String title,
    required String body,
  }) {
    // Remove existing overlay if present
    _removeOverlay();

    // Create new overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: _NotificationCard(
          title: title,
          body: body,
          onDismiss: _removeOverlay,
        ),
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      _removeOverlay();
    });
  }

  /// Remove overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Notification Card Widget
class _NotificationCard extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.navyLight,
                  AppColors.navy,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cyanNeon.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyanNeon.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _dismiss,
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
                        color: AppColors.cyanNeon.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.cyanNeon,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: AppColors.ivory,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.body,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.grey,
                        size: 18,
                      ),
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
