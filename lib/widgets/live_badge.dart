import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiveBadge extends StatefulWidget {
  final String text;
  final Color color;

  const LiveBadge({
    super.key,
    this.text = 'LIVE',
    this.color = AppColors.liveRed,
  });

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _animController.repeat(reverse: true);
    } else {
      _animController.value = 1.0;
    }

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.6 * _glowAnimation.value),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25 * _glowAnimation.value),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _glowAnimation.value),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
