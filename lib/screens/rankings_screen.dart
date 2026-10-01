import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';

class RankingsScreen extends StatefulWidget {
  final CricketDataService dataService;

  const RankingsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFormat = 'T20I';

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
        title: const Text('ICC PLAYER RANKINGS'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedFormat,
            color: AppColors.cardSurface,
            onSelected: (val) {
              setState(() {
                _selectedFormat = val;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'T20I', child: Text('T20I Rankings')),
              const PopupMenuItem(value: 'ODI', child: Text('ODI Rankings')),
              const PopupMenuItem(value: 'Test', child: Text('Test Rankings')),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedFormat,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 16),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'TOP BATTERS'),
            Tab(text: 'TOP BOWLERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingsList(widget.dataService.rankingsT20Batting, 'Batting'),
          _buildRankingsList(widget.dataService.rankingsT20Bowling, 'Bowling'),
        ],
      ),
    );
  }

  Widget _buildRankingsList(List<PlayerRanking> rankings, String category) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Number 1 Spotlight Card
        if (rankings.isNotEmpty) _buildSpotlightCard(rankings.first, category),

        const SizedBox(height: 16),

        const Text(
          'OFFICIAL TOP RANKED PLAYERS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: rankings.map((player) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${player.rank}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: player.rank == 1
                                  ? AppColors.boundaryAmber
                                  : player.rank <= 3
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        // Flag
                        Text(player.flagEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        // Name & Team
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${player.teamShort} • $_selectedFormat',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Movement
                        if (player.pointsDiff != '0')
                          Row(
                            children: [
                              Icon(
                                player.pointsDiff.startsWith('+') ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                color: player.pointsDiff.startsWith('+') ? AppColors.secondary : AppColors.liveRed,
                                size: 16,
                              ),
                              Text(
                                player.pointsDiff,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: player.pointsDiff.startsWith('+') ? AppColors.secondary : AppColors.liveRed,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(width: 12),
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${player.rating}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (player != rankings.last) const Divider(color: AppColors.border, height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpotlightCard(PlayerRanking leader, String category) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF223559),
            Color(0xFF16223B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.boundaryAmber.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.boundaryAmber.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.boundaryAmber.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.boundaryAmber),
            ),
            child: const Icon(Icons.emoji_events, color: AppColors.boundaryAmber, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.boundaryAmber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'WORLD NO. 1',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${leader.flagEmoji} ${leader.teamShort}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  leader.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                Text(
                  'Rating: ${leader.rating} pts • $_selectedFormat $category',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
