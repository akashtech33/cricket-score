import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/scorecard_model.dart';
import '../models/commentary_model.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ball_circle.dart';
import '../widgets/live_badge.dart';
import '../widgets/win_probability_bar.dart';
import '../widgets/worm_chart.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  final CricketDataService dataService;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.dataService,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedScorecardInnings = 2; // Default to current/chasing innings

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final match = widget.dataService.getMatchById(widget.matchId);
        if (match == null) {
          return const Scaffold(
            body: Center(child: Text('Match not found')),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Match score link copied to clipboard!')),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorWeight: 3,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'LIVE COMMENTARY'),
                Tab(text: 'SCORECARD'),
                Tab(text: 'OVERS & CHARTS'),
                Tab(text: 'MATCH INFO'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Sticky Live Scoreboard Header
              _buildTopScoreboard(match),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCommentaryTab(match),
                    _buildScorecardTab(match),
                    _buildChartsTab(match),
                    _buildMatchInfoTab(match),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopScoreboard(CricketMatch match) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Team 1
              Expanded(
                child: Row(
                  children: [
                    Text(match.team1.flagEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.team1.shortCode,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          match.team1.scoreDisplay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          match.team1.oversDisplay,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Center Target / Equation
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      match.target != null ? 'TARGET ${match.target}' : '1ST INNINGS',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.boundaryAmber,
                      ),
                    ),
                  ),
                  if (match.status == MatchStatus.live) ...[
                    const SizedBox(height: 4),
                    Text(
                      'CRR: ${match.currentRunRate.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),

              // Team 2
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (match.team2.isBatting)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary),
                              ),
                            Text(
                              match.team2.shortCode,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Text(
                          match.team2.scoreDisplay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          match.team2.oversDisplay,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(match.team2.flagEmoji, style: const TextStyle(fontSize: 22)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Equation Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.currentEquation,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.boundaryAmber,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (match.requiredRunRate > 0)
                  Text(
                    'RRR: ${match.requiredRunRate.toStringAsFixed(2)}',
                    style: const TextStyle(
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
    );
  }

  // TAB 1: LIVE COMMENTARY
  Widget _buildCommentaryTab(CricketMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Simulation Interactive Bar
        if (match.status == MatchStatus.live) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bolt, color: AppColors.primary, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'LIVE SIMULATOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Speed options
                        _buildSpeedChip(1.0),
                        const SizedBox(width: 4),
                        _buildSpeedChip(2.0),
                        const SizedBox(width: 4),
                        _buildSpeedChip(4.0),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Auto-Play toggle
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.dataService.isAutoSimulating
                              ? AppColors.cardElevated
                              : AppColors.secondary,
                          foregroundColor: widget.dataService.isAutoSimulating
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          widget.dataService.toggleAutoSimulation();
                        },
                        icon: Icon(
                          widget.dataService.isAutoSimulating ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(
                          widget.dataService.isAutoSimulating ? 'Pause Live Stream' : 'Resume Live Stream',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Manual Step Next Ball
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        widget.dataService.stepNextBall(match.id);
                      },
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('Next Ball', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Current Batters & Bowler Card
        if (match.striker != null && match.bowler != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Batters
                _buildLiveBatterRow(match.striker!, isStriker: true),
                if (match.nonStriker != null) ...[
                  const Divider(color: AppColors.border, height: 16),
                  _buildLiveBatterRow(match.nonStriker!, isStriker: false),
                ],
                const Divider(color: AppColors.border, height: 16),
                // Bowler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_baseball_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          match.bowler!.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      '${match.bowler!.wickets}/${match.bowler!.runs} (${match.bowler!.overs} ov) • Econ ${match.bowler!.economy.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Win Predictor
        WinProbabilityBar(
          team1Code: match.team1.shortCode,
          team2Code: match.team2.shortCode,
          team1Probability: match.winProbabilityTeam1,
          team2Probability: match.winProbabilityTeam2,
        ),
        const SizedBox(height: 16),

        const Text(
          'BALL BY BALL COMMENTARY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),

        // Commentary List
        if (match.commentary.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('Match commentary will begin at toss.'),
            ),
          )
        else
          ...match.commentary.map((item) => _buildCommentaryTile(item)),
      ],
    );
  }

  Widget _buildSpeedChip(double speed) {
    final isSelected = widget.dataService.simSpeed == speed;
    return GestureDetector(
      onTap: () => widget.dataService.setSimulationSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${speed.toInt()}x',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBatterRow(BatterScore batter, {required bool isStriker}) {
    return Row(
      children: [
        Row(
          children: [
            if (isStriker)
              const Icon(Icons.sports_cricket, size: 14, color: AppColors.secondary)
            else
              const SizedBox(width: 14),
            const SizedBox(width: 6),
            Text(
              '${batter.name}${isStriker ? '*' : ''}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isStriker ? FontWeight.w800 : FontWeight.w600,
                color: isStriker ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '${batter.runs}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        Text(
          '(${batter.balls})',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Text(
          '${batter.fours}x4  ${batter.sixes}x6',
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

  Widget _buildCommentaryTile(CommentaryItem item) {
    if (item.isOverSummary) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            Text(
              item.description,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Over & Ball Circle
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
          // Content
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

  // TAB 2: FULL SCORECARD
  Widget _buildScorecardTab(CricketMatch match) {
    final scorecard1 = match.innings1;
    final scorecard2 = match.innings2;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Innings Selector Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildInningsSelectBtn(
                  title: '${scorecard1.teamShort} Innings',
                  subtitle: '${scorecard1.runs}/${scorecard1.wickets}',
                  isSelected: _selectedScorecardInnings == 1,
                  onTap: () => setState(() => _selectedScorecardInnings = 1),
                ),
              ),
              if (scorecard2 != null)
                Expanded(
                  child: _buildInningsSelectBtn(
                    title: '${scorecard2.teamShort} Innings',
                    subtitle: '${scorecard2.runs}/${scorecard2.wickets}',
                    isSelected: _selectedScorecardInnings == 2,
                    onTap: () => setState(() => _selectedScorecardInnings = 2),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Display Chosen Innings
        if (_selectedScorecardInnings == 1)
          _buildInningsScorecardView(scorecard1)
        else if (scorecard2 != null)
          _buildInningsScorecardView(scorecard2),
      ],
    );
  }

  Widget _buildInningsSelectBtn({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.black : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black87 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsScorecardView(InningsScorecard innings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Innings Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${innings.teamName.toUpperCase()} INNINGS',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              Text(
                '${innings.runs}/${innings.wickets} (${innings.overs.toStringAsFixed(1)} ov)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Batting Table
        const Text(
          'BATTING',
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
              // Header
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

              // Rows
              ...innings.batters.map((b) => _buildScorecardBatterRow(b)),

              // Extras Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Extras', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      '${innings.extras.total} (w ${innings.extras.wides}, nb ${innings.extras.noBalls}, b ${innings.extras.byes}, lb ${innings.extras.legByes})',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Total Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    Text(
                      '${innings.runs}/${innings.wickets} (${innings.overs.toStringAsFixed(1)} ov)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (innings.didNotBat.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Yet to bat: ${innings.didNotBat.join(', ')}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],

        const SizedBox(height: 20),

        // Bowling Table
        const Text(
          'BOWLING',
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: const [
                    Expanded(flex: 4, child: Text('Bowler', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('O', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('M', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('R', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('W', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    Expanded(flex: 2, child: Text('ECON', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Rows
              ...innings.bowlers.map((bw) => _buildScorecardBowlerRow(bw)),
            ],
          ),
        ),

        // Fall of Wickets
        if (innings.fallOfWickets.isNotEmpty) ...[
          const SizedBox(height: 20),
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
              children: innings.fallOfWickets.map((fow) {
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

  Widget _buildScorecardBatterRow(BatterScore batter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${batter.name}${batter.isStriker ? '*' : ''}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: batter.isStriker ? FontWeight.w800 : FontWeight.w600,
                    color: batter.isStriker ? AppColors.secondary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  batter.dismissal,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text('${batter.runs}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
          Expanded(flex: 1, child: Text('${batter.balls}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 1, child: Text('${batter.fours}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text('${batter.sixes}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(batter.strikeRate.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildScorecardBowlerRow(BowlerScore bowler) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(bowler.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          Expanded(flex: 1, child: Text(bowler.overs.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 1, child: Text('${bowler.maidens}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 1, child: Text('${bowler.runs}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text('${bowler.wickets}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.boundaryAmber))),
          Expanded(flex: 2, child: Text(bowler.economy.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // TAB 3: OVERS & CHARTS
  Widget _buildChartsTab(CricketMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Worm Chart
        WormChart(
          team1Runs: match.runProgressionTeam1,
          team2Runs: match.runProgressionTeam2,
          team1Code: match.team1.shortCode,
          team2Code: match.team2.shortCode,
        ),

        const SizedBox(height: 18),

        // Phase Breakdown Card (Powerplay vs Middle vs Death)
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
                'PHASE ANALYSIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildPhaseRow(
                phase: 'Powerplay (1 - 6 ov)',
                team1Stat: '65/2 (10.8 RR)',
                team2Stat: '68/1 (11.3 RR)',
                team1Code: match.team1.shortCode,
                team2Code: match.team2.shortCode,
              ),
              const Divider(color: AppColors.border, height: 16),
              _buildPhaseRow(
                phase: 'Middle Overs (7 - 15 ov)',
                team1Stat: '85/2 (9.4 RR)',
                team2Stat: '83/3 (9.2 RR)',
                team1Code: match.team1.shortCode,
                team2Code: match.team2.shortCode,
              ),
              const Divider(color: AppColors.border, height: 16),
              _buildPhaseRow(
                phase: 'Death Overs (16 - 20 ov)',
                team1Stat: '37/2 (9.25 RR)',
                team2Stat: '17/0 (11.3 RR - In progress)',
                team1Code: match.team1.shortCode,
                team2Code: match.team2.shortCode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseRow({
    required String phase,
    required String team1Stat,
    required String team2Stat,
    required String team1Code,
    required String team2Code,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          phase,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.boundaryAmber),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$team1Code: $team1Stat',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              '$team2Code: $team2Stat',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  // TAB 4: MATCH INFO & SQUADS
  Widget _buildMatchInfoTab(CricketMatch match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Match Details Card
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
                'MATCH INFORMATION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Series', match.series),
              _buildInfoRow('Match', '${match.stage}, ${match.matchType.name.toUpperCase()}'),
              _buildInfoRow('Date & Time', match.dateStr),
              _buildInfoRow('Toss', match.toss),
              _buildInfoRow('Venue', match.venue),
              _buildInfoRow('Pitch Report', match.pitchReport),
              _buildInfoRow('Weather', match.weather),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Squads
        if (match.team1Squad.isNotEmpty || match.team2Squad.isNotEmpty) ...[
          const Text(
            'PLAYING XIs',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // Side-by-side or stacked squad
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
                Text(
                  '${match.team2.name} (${match.team2.shortCode})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: match.team2Squad.map((player) {
                    return Chip(
                      label: Text(
                        '${player.name}${player.isCaptain ? ' (c)' : ''}${player.isKeeper ? ' (wk)' : ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: AppColors.cardElevated,
                    );
                  }).toList(),
                ),
                const Divider(color: AppColors.border, height: 24),
                Text(
                  '${match.team1.name} (${match.team1.shortCode})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.boundaryAmber),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: match.team1Squad.map((player) {
                    return Chip(
                      label: Text(
                        '${player.name}${player.isCaptain ? ' (c)' : ''}${player.isKeeper ? ' (wk)' : ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: AppColors.cardElevated,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
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
