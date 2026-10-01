import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../theme/app_colors.dart';
import 'live_badge.dart';
import 'ball_circle.dart';

class MatchCard extends StatelessWidget {
  final CricketMatch match;
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: match.status == MatchStatus.live
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Series & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${match.series} • ${match.stage}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (match.status == MatchStatus.live)
                  const LiveBadge(text: 'LIVE')
                else if (match.status == MatchStatus.upcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      match.dateStr.split('•').last.trim(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'RESULT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Team 1 Row
            _buildTeamRow(match.team1),

            const SizedBox(height: 8),

            // Team 2 Row
            _buildTeamRow(match.team2),

            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),

            // Bottom Status / Equation & Recent Balls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.resultSummary.isNotEmpty ? match.resultSummary : match.currentEquation,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: match.status == MatchStatus.live
                          ? AppColors.boundaryAmber
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (match.status == MatchStatus.live && match.recentBalls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: match.recentBalls.take(4).map((ball) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: BallCircle(outcome: ball, size: 20),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(MatchTeam team) {
    return Row(
      children: [
        Text(team.flagEmoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (team.isBatting) ...[
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (team.runs > 0 || team.overs > 0) ...[
          Text(
            team.scoreDisplay,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            team.oversDisplay,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ] else ...[
          const Text(
            'Yet to bat',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
