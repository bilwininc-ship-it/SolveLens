// Neon scanning line animation overlay
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanAnimationOverlay extends StatefulWidget {
  const ScanAnimationOverlay({super.key});

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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
      color: AppTheme.navyDark.withOpacity(0.7),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: ScanLinePainter(progress: _animation.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double lineY = size.height * progress;

    // Main scan line
    final Paint linePaint = Paint()
      ..color = AppTheme.premiumGold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [
          AppTheme.premiumGold.withOpacity(0.0),
          AppTheme.premiumGold,
          AppTheme.premiumGold.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, lineY - 20, size.width, 40));

    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      linePaint,
    );

    // Glow effect
    final Paint glowPaint = Paint()
      ..color = AppTheme.premiumGold.withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      glowPaint,
    );

    // Grid lines behind scan line
    final Paint gridPaint = Paint()
      ..color = AppTheme.premiumGold.withOpacity(0.1)
      ..strokeWidth = 1;

    for (double i = 0; i <= lineY; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
