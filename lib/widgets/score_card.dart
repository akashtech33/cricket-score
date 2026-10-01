import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../theme/app_colors.dart';
import 'live_badge.dart';

class ScoreCardWidget extends StatelessWidget {
  final CricketMatch match;

  const ScoreCardWidget({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final battingTeam = match.currentInningsIndex == 1 ? match.team1 : match.team2;
    final bowlingTeam = match.currentInningsIndex == 1 ? match.team2 : match.team1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF131D33),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Match Title & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${match.series.toUpperCase()} • ${match.stage}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (match.status == MatchStatus.live)
                const LiveBadge(text: 'LIVE')
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.status.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Main Score Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Batting Team & Big Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(battingTeam.flagEmoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            battingTeam.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          battingTeam.scoreDisplay,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            battingTeam.oversDisplay,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Bowling Team (Opposition) Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        bowlingTeam.shortCode,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Text(bowlingTeam.flagEmoji, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text(
                    bowlingTeam.scoreDisplay,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                  ),
                  Text(
                    bowlingTeam.oversDisplay,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (match.target != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.boundaryAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Target: ${match.target}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.boundaryAmber),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Run Rate & Target Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CRR: ${match.currentRunRate.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                if (match.requiredRunRate > 0)
                  Text(
                    'RRR: ${match.requiredRunRate.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.boundaryAmber),
                  ),
                Flexible(
                  child: Text(
                    match.currentEquation,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
