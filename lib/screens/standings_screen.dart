import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';

class StandingsScreen extends StatefulWidget {
  final CricketDataService dataService;

  const StandingsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('POINTS TABLE & STANDINGS'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'ICC T20 WORLD CUP'),
            Tab(text: 'IPL 2026'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorldCupTab(),
          _buildIplTab(),
        ],
      ),
    );
  }

  Widget _buildWorldCupTab() {
    final groups = widget.dataService.worldCupStandings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.groupName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top 2 Qualify for Semis',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildStandingsTable(group.standings),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildIplTab() {
    final iplEntries = [
      PointsTableEntry(rank: 1, teamName: 'Kolkata Knight Riders', shortCode: 'KKR', flagEmoji: '🟣', played: 14, won: 10, lost: 4, netRunRate: 1.428, points: 20, formGuide: ['W', 'W', 'L', 'W', 'W'], isQualified: true),
      PointsTableEntry(rank: 2, teamName: 'Sunrisers Hyderabad', shortCode: 'SRH', flagEmoji: '🟠', played: 14, won: 9, lost: 5, netRunRate: 0.912, points: 18, formGuide: ['W', 'L', 'W', 'W', 'W'], isQualified: true),
      PointsTableEntry(rank: 3, teamName: 'Rajasthan Royals', shortCode: 'RR', flagEmoji: '🩷', played: 14, won: 8, lost: 6, netRunRate: 0.354, points: 16, formGuide: ['L', 'L', 'L', 'W', 'L'], isQualified: true),
      PointsTableEntry(rank: 4, teamName: 'Royal Challengers Bengaluru', shortCode: 'RCB', flagEmoji: '🔴', played: 14, won: 7, lost: 7, netRunRate: 0.459, points: 14, formGuide: ['W', 'W', 'W', 'W', 'W'], isQualified: true),
      PointsTableEntry(rank: 5, teamName: 'Chennai Super Kings', shortCode: 'CSK', flagEmoji: '🦁', played: 14, won: 7, lost: 7, netRunRate: 0.392, points: 14, formGuide: ['L', 'W', 'L', 'W', 'L']),
      PointsTableEntry(rank: 6, teamName: 'Delhi Capitals', shortCode: 'DC', flagEmoji: '🔵', played: 14, won: 7, lost: 7, netRunRate: -0.377, points: 14, formGuide: ['W', 'L', 'W', 'L', 'W']),
      PointsTableEntry(rank: 7, teamName: 'Lucknow Super Giants', shortCode: 'LSG', flagEmoji: '🩵', played: 14, won: 7, lost: 7, netRunRate: -0.667, points: 14, formGuide: ['W', 'L', 'L', 'L', 'W']),
      PointsTableEntry(rank: 8, teamName: 'Gujarat Titans', shortCode: 'GT', flagEmoji: '⚓', played: 14, won: 5, lost: 7, netRunRate: -1.063, points: 12, formGuide: ['L', 'W', 'L', 'L', 'L']),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStandingsTable(iplEntries),
      ],
    );
  }

  Widget _buildStandingsTable(List<PointsTableEntry> standings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Table Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: const [
                  SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 100, child: Text('TEAM', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 32, child: Text('P', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 32, child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 32, child: Text('L', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 36, child: Text('PTS', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  SizedBox(width: 68, child: Text('NRR', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  SizedBox(width: 10),
                  SizedBox(width: 90, child: Text('FORM', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Table Rows
            ...standings.map((entry) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Row(
                            children: [
                              Text(
                                '${entry.rank}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: entry.isQualified ? AppColors.secondary : AppColors.textSecondary,
                                ),
                              ),
                              if (entry.isQualified)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(left: 3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Text(entry.flagEmoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                entry.shortCode,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text('${entry.played}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text('${entry.won}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text('${entry.lost}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${entry.points}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 68,
                          child: Text(
                            entry.nrrDisplay,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: entry.netRunRate >= 0 ? AppColors.secondary : AppColors.liveRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: entry.formGuide.map((result) {
                              final isWin = result == 'W';
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 14,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isWin ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.liveRed.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: isWin ? AppColors.secondary : AppColors.liveRed,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  result,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: isWin ? AppColors.secondary : AppColors.liveRed,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
