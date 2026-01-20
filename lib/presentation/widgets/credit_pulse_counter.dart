// Credit Pulse Counter - Elite 300ms Pulse Effect
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CreditPulseCounter extends StatefulWidget {
  final int used;
  final int total;
  final VoidCallback? onTap;

  const CreditPulseCounter({
    super.key,
    required this.used,
    required this.total,
    this.onTap,
  });

  @override
  State<CreditPulseCounter> createState() => _CreditPulseCounterState();
}

class _CreditPulseCounterState extends State<CreditPulseCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  int _previousCredits = 0;

  @override
  void initState() {
    super.initState();
    _previousCredits = widget.used;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Elite 300ms pulse
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(CreditPulseCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger pulse when credits change (decrease)
    if (oldWidget.used != widget.used && widget.used > _previousCredits) {
      _triggerPulse();
      _previousCredits = widget.used;
    }
  }

  void _triggerPulse() {
    _pulseController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.used}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                  Text(
                    ' / ${widget.total}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0A192F).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
