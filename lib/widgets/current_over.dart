import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ball_circle.dart';

class CurrentOverWidget extends StatelessWidget {
  final List<String> recentBalls;

  const CurrentOverWidget({
    super.key,
    required this.recentBalls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Text(
            'THIS OVER:',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: recentBalls.isEmpty
              ? const Text(
                  'Yet to begin',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                )
              : SizedBox(
                  height: 26,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentBalls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      return BallCircle(outcome: recentBalls[index], size: 24);
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
