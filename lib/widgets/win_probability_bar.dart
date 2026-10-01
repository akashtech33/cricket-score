import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WinProbabilityBar extends StatelessWidget {
  final String team1Code;
  final String team2Code;
  final double team1Probability;
  final double team2Probability;

  const WinProbabilityBar({
    super.key,
    required this.team1Code,
    required this.team2Code,
    required this.team1Probability,
    required this.team2Probability,
  });

  @override
  Widget build(BuildContext context) {
    final t1Norm = (team1Probability / 100.0).clamp(0.05, 0.95);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$team1Code ${team1Probability.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Text(
              'WIN PREDICTOR',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.textMuted,
              ),
            ),
            Row(
              children: [
                Text(
                  '${team2Probability.toStringAsFixed(0)}% $team2Code',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final t1Width = (totalWidth * t1Norm).clamp(4.0, totalWidth - 4.0);
              return SizedBox(
                height: 6,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: t1Width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primary,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
