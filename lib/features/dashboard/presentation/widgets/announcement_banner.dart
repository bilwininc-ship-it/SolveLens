import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Announcement Banner - Scrolling marquee for dashboard announcements
/// Displays Remote Config messages in an elegant, animated banner
class AnnouncementBanner extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AnnouncementBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyanNeon.withOpacity(0.1),
            AppColors.info.withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.cyanNeon.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Scrolling announcement text
          ClipRect(
            child: SlideTransition(
              position: _animation,
              child: Row(
                children: [
                  _buildAnnouncementText(),
                  const SizedBox(width: 100),
                  _buildAnnouncementText(),
                ],
              ),
            ),
          ),

          // Dismiss button (optional)
          if (widget.onDismiss != null)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.navy.withOpacity(0.0),
                      AppColors.navy,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: 18,
                  ),
                  onPressed: widget.onDismiss,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementText() {
    return Row(
      children: [
        const Icon(
          Icons.campaign_rounded,
          color: AppColors.cyanNeon,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          widget.message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.greyLight,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
