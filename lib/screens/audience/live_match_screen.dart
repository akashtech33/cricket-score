import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_model.dart';
import '../../models/commentary_model.dart';
import '../../providers/match_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ball_circle.dart';
import '../../widgets/current_over.dart';
import '../../widgets/live_badge.dart';
import '../../widgets/player_card.dart';
import '../../widgets/score_card.dart';
import '../../widgets/win_probability_bar.dart';

class LiveMatchScreen extends StatefulWidget {
  final String matchId;

  const LiveMatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    // Real-time Firestore StreamBuilder: No manual refresh required!
    return StreamBuilder<CricketMatch?>(
      stream: firestoreService.getMatchStream(widget.matchId),
      initialData: matchProvider.matches.firstWhere(
        (m) => m.id == widget.matchId,
        orElse: () => matchProvider.matches.first,
      ),
      builder: (context, snapshot) {
        final match = snapshot.data;

        if (match == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('MATCH NOT FOUND')),
            body: const Center(child: Text('Match data unavailable')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match.team1.shortCode} vs ${match.team2.shortCode}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${match.series} • ${match.stage}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            actions: [
              if (match.status == MatchStatus.live)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(child: LiveBadge(text: 'LIVE')),
                ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Share Live Score',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live match link copied!')),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'LIVE COMMENTARY'),
                Tab(text: 'FULL SCORECARD'),
                Tab(text: 'MATCH INFO'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildLiveStreamTab(match),
              _buildScorecardTab(match),
              _buildMatchInfoTab(match),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveStreamTab(CricketMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Score Card Summary
        ScoreCardWidget(match: match),

        const SizedBox(height: 14),

        // Batsmen Pair & Bowler Spell (Read-only, no admin controls)
        PlayerCardWidget(
          striker: match.striker,
          nonStriker: match.nonStriker,
          bowler: match.bowler,
        ),

        const SizedBox(height: 14),

        // Current Over Deliveries Strip
        CurrentOverWidget(recentBalls: match.recentBalls),

        const SizedBox(height: 14),

        // Win Predictor Gauge
        WinProbabilityBar(
          team1Code: match.team1.shortCode,
          team2Code: match.team2.shortCode,
          team1Probability: match.winProbabilityTeam1,
          team2Probability: match.winProbabilityTeam2,
        ),

        const SizedBox(height: 20),

        // Live Commentary Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'LIVE BALL-BY-BALL COMMENTARY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              'Auto-updating',
              style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (match.commentary.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                'Live commentary will begin shortly.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...match.commentary.map((comm) => _buildCommentaryTile(comm)),
      ],
    );
  }

  Widget _buildCommentaryTile(CommentaryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isWicket
              ? AppColors.liveRed.withValues(alpha: 0.4)
              : item.isBoundary || item.isSix
                  ? AppColors.boundaryAmber.withValues(alpha: 0.3)
                  : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                item.over,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              BallCircle(outcome: item.outcome, size: 28),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: item.isWicket
                        ? AppColors.liveRed
                        : item.isSix
                            ? AppColors.sixPurple
                            : item.isBoundary
                                ? AppColors.boundaryAmber
                                : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardTab(CricketMatch match) {
    final scorecard = match.currentInningsIndex == 1 ? match.innings1 : (match.innings2 ?? match.innings1);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Innings Header Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${scorecard.teamName.toUpperCase()} INNINGS',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              Text(
                '${scorecard.runs}/${scorecard.wickets} (${scorecard.overs.toStringAsFixed(1)} ov)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Batters Table
        const Text(
          'BATTING SCORECARD',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: const [
                    Expanded(flex: 4, child: Text('Batter', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('R', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('B', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('4s', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('6s', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 2, child: Text('SR', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              ...scorecard.batters.map((b) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          '${b.name}${b.isStriker ? '*' : ''}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: b.isStriker ? FontWeight.w800 : FontWeight.w600,
                            color: b.isStriker ? AppColors.secondary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: Text('${b.runs}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
                      Expanded(flex: 1, child: Text('${b.balls}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                      Expanded(flex: 1, child: Text('${b.fours}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      Expanded(flex: 1, child: Text('${b.sixes}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(b.strikeRate.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Fall of Wickets
        if (scorecard.fallOfWickets.isNotEmpty) ...[
          const Text(
            'FALL OF WICKETS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: scorecard.fallOfWickets.map((fow) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${fow.score}/${fow.wicketNumber}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.boundaryAmber),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${fow.batter} (${fow.over} ov)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMatchInfoTab(CricketMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MATCH FACTS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Series', match.series),
              _buildInfoRow('Stage', match.stage),
              _buildInfoRow('Venue', match.venue),
              _buildInfoRow('Toss', match.toss),
              _buildInfoRow('Pitch Report', match.pitchReport),
              _buildInfoRow('Weather', match.weather),
              _buildInfoRow('Current Status', match.status.name.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
