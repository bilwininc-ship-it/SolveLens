// Academic Skeleton - Paper Surface Thinking Indicator
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AcademicSkeleton extends StatefulWidget {
  final String message;
  
  const AcademicSkeleton({
    super.key,
    this.message = 'Professor is thinking...',
  });

  @override
  State<AcademicSkeleton> createState() => _AcademicSkeletonState();
}

class _AcademicSkeletonState extends State<AcademicSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Professor" label
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A192F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Professor',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A192F).withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Paper Surface Container with Skeleton Lines
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7), // Warm paper white
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0A192F).withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated thinking indicator
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: const Color(0xFF0A192F).withOpacity(0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A192F).withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Skeleton Lines (Academic Draft)
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonLine(1.0, _shimmerAnimation.value),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(0.85, _shimmerAnimation.value),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(0.95, _shimmerAnimation.value),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(0.7, _shimmerAnimation.value),
                        const SizedBox(height: 20),
                        _buildSkeletonLine(0.9, _shimmerAnimation.value),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(0.8, _shimmerAnimation.value),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLine(double widthFactor, double shimmerValue) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7 * widthFactor,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            const Color(0xFF0A192F).withOpacity(0.08),
            const Color(0xFF0A192F).withOpacity(0.12 + shimmerValue.abs() * 0.03),
            const Color(0xFF0A192F).withOpacity(0.08),
          ],
        ),
      ),
    );
  }
}
