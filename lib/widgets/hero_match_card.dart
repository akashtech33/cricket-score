import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../theme/app_colors.dart';
import 'live_badge.dart';
import 'ball_circle.dart';
import 'win_probability_bar.dart';

class HeroMatchCard extends StatelessWidget {
  final CricketMatch match;
  final VoidCallback onTap;

  const HeroMatchCard({
    super.key,
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B2C4E),
              Color(0xFF131F37),
              Color(0xFF0F172A),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Series & Live Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.series.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${match.stage} • ${match.venue}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (match.status == MatchStatus.live)
                    const LiveBadge(text: 'LIVE')
                  else if (match.status == MatchStatus.completed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
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

              const SizedBox(height: 16),

              // Scores Section
              Row(
                children: [
                  // Team 1
                  Expanded(
                    child: _buildTeamScore(
                      name: match.team1.name,
                      shortCode: match.team1.shortCode,
                      flag: match.team1.flagEmoji,
                      score: match.team1.scoreDisplay,
                      overs: match.team1.oversDisplay,
                      isBatting: match.team1.isBatting,
                      accentColor: match.team1.primaryColor,
                    ),
                  ),

                  // VS / Match equation pill in middle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (match.target != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'T: ${match.target}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.boundaryAmber,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Team 2
                  Expanded(
                    child: _buildTeamScore(
                      name: match.team2.name,
                      shortCode: match.team2.shortCode,
                      flag: match.team2.flagEmoji,
                      score: match.team2.scoreDisplay,
                      overs: match.team2.oversDisplay,
                      isBatting: match.team2.isBatting,
                      accentColor: match.team2.primaryColor,
                      alignRight: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Current Status / Equation Highlight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.boundaryAmber.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.electric_bolt_rounded,
                      size: 15,
                      color: AppColors.boundaryAmber,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.currentEquation,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (match.status == MatchStatus.live) ...[
                      Text(
                        'CRR: ${match.currentRunRate.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (match.requiredRunRate > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'RRR: ${match.requiredRunRate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.boundaryAmber,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Striker, Bowler & Recent Balls (If Live)
              if (match.status == MatchStatus.live && match.striker != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Batting Striker
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_cricket, size: 13, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${match.striker!.name}*',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${match.striker!.runs} (${match.striker!.balls}) • SR: ${match.striker!.strikeRate.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bowler
                    if (match.bowler != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.sports_baseball_outlined, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  match.bowler!.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Text(
                              '${match.bowler!.wickets}/${match.bowler!.runs} (${match.bowler!.overs} ov)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Recent Balls Strip
                Row(
                  children: [
                    const Text(
                      'Recent: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        height: 26,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: match.recentBalls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            return BallCircle(
                              outcome: match.recentBalls[index],
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Win Predictor Gauge
              WinProbabilityBar(
                team1Code: match.team1.shortCode,
                team2Code: match.team2.shortCode,
                team1Probability: match.winProbabilityTeam1,
                team2Probability: match.winProbabilityTeam2,
              ),

              const SizedBox(height: 14),

              // CTA row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Partnership: ${match.partnershipRuns} (${match.partnershipBalls})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        'Match Center',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore({
    required String name,
    required String shortCode,
    required String flag,
    required String score,
    required String overs,
    required bool isBatting,
    required Color accentColor,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight) ...[
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
            ],
            Text(
              shortCode,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (isBatting) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
            ],
            if (alignRight) ...[
              const SizedBox(width: 8),
              Text(flag, style: const TextStyle(fontSize: 20)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                overs,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
