import 'package:flutter/material.dart';
import '../models/scorecard_model.dart';
import '../theme/app_colors.dart';

class PlayerCardWidget extends StatelessWidget {
  final BatterScore? striker;
  final BatterScore? nonStriker;
  final BowlerScore? bowler;
  final VoidCallback? onSwapStrikers;

  const PlayerCardWidget({
    super.key,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    this.onSwapStrikers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Batters Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BATSMEN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              if (onSwapStrikers != null)
                GestureDetector(
                  onTap: onSwapStrikers,
                  child: Row(
                    children: const [
                      Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Swap Strike',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Striker Row
          if (striker != null) _buildBatterRow(striker!, isStriker: true),

          // Non-Striker Row
          if (nonStriker != null) ...[
            const Divider(color: AppColors.border, height: 16),
            _buildBatterRow(nonStriker!, isStriker: false),
          ],

          const Divider(color: AppColors.border, height: 20),

          // Bowler Header & Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'CURRENT BOWLER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (bowler != null)
            Row(
              children: [
                const Icon(Icons.sports_baseball_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bowler!.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${bowler!.wickets}/${bowler!.runs}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.boundaryAmber),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${bowler!.overs.toStringAsFixed(1)} ov)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                Text(
                  'Econ ${bowler!.economy.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBatterRow(BatterScore batter, {required bool isStriker}) {
    return Row(
      children: [
        if (isStriker)
          const Icon(Icons.sports_cricket, size: 14, color: AppColors.secondary)
        else
          const SizedBox(width: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${batter.name}${isStriker ? '*' : ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isStriker ? FontWeight.w800 : FontWeight.w600,
              color: isStriker ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '${batter.runs}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 4),
        Text(
          '(${batter.balls})',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Text(
          '${batter.fours}x4 ${batter.sixes}x6',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Text(
          'SR: ${batter.strikeRate.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ],
    );
  }
}
