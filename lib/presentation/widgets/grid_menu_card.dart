// Grid Menu Card - Academic Research Station Features
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GridMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const GridMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<GridMenuCard> createState() => _GridMenuCardState();
}

class _GridMenuCardState extends State<GridMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryNavy.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 12,
              color: AppTheme.primaryNavy.withOpacity(0.06),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Hover effect overlay
            if (_isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryNavy.withOpacity(0.02),
                        AppTheme.cyanNeon.withOpacity(0.03),
                      ],
                    ),
                  ),
                ),
              ),
            // Accent border on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                decoration: BoxDecoration(
                  color: _isHovered ? AppTheme.cyanNeon : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: AppTheme.primaryNavy,
                          size: 24,
                        ),
                      ),
                      // Indicator dot
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isHovered ? 1.0 : 0.0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.cyanNeon,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: AppTheme.primaryNavy.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
