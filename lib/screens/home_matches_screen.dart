import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_match_card.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class HomeMatchesScreen extends StatefulWidget {
  final CricketDataService dataService;

  const HomeMatchesScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<HomeMatchesScreen> createState() => _HomeMatchesScreenState();
}

class _HomeMatchesScreenState extends State<HomeMatchesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final matches = widget.dataService.matches;
        final featuredMatch = widget.dataService.featuredMatch;

        // Filter matches
        List<CricketMatch> filteredMatches = matches;
        if (_selectedFilter == 'Live') {
          filteredMatches = matches.where((m) => m.status == MatchStatus.live).toList();
        } else if (_selectedFilter == 'Upcoming') {
          filteredMatches = matches.where((m) => m.status == MatchStatus.upcoming).toList();
        } else if (_selectedFilter == 'Completed') {
          filteredMatches = matches.where((m) => m.status == MatchStatus.completed).toList();
        } else if (_selectedFilter == 'T20 World Cup') {
          filteredMatches = matches.where((m) => m.series.contains('World Cup')).toList();
        } else if (_selectedFilter == 'IPL') {
          filteredMatches = matches.where((m) => m.series.contains('IPL')).toList();
        }

        // Separate non-featured matches for the lower list
        final otherMatches = filteredMatches.where((m) => m.id != featuredMatch.id).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_cricket,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'CRICPULSE LIVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Fastest Live Cricket Scores & Hub',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Auto-play quick indicator
              IconButton(
                tooltip: widget.dataService.isAutoSimulating ? 'Live Engine Active' : 'Live Engine Paused',
                icon: Icon(
                  widget.dataService.isAutoSimulating ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                  color: widget.dataService.isAutoSimulating ? AppColors.secondary : AppColors.textMuted,
                  size: 22,
                ),
                onPressed: () {
                  widget.dataService.toggleAutoSimulation();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        widget.dataService.isAutoSimulating
                            ? 'Live simulation resumed (updates every ball)!'
                            : 'Live simulation paused',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Score notifications enabled for live matches!')),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardSurface,
            onRefresh: () async {
              widget.dataService.stepNextBall();
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Top Live Simulation Notice
                _buildLiveTickerNotice(),

                // Hero Match (IND vs AUS Final)
                if (_selectedFilter == 'All' || _selectedFilter == 'Live' || _selectedFilter == 'T20 World Cup')
                  HeroMatchCard(
                    match: featuredMatch,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchDetailScreen(
                            matchId: featuredMatch.id,
                            dataService: widget.dataService,
                          ),
                        ),
                      );
                    },
                  ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Live'),
                        _buildFilterChip('Upcoming'),
                        _buildFilterChip('Completed'),
                        _buildFilterChip('T20 World Cup'),
                        _buildFilterChip('IPL'),
                      ],
                    ),
                  ),
                ),

                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MATCHES (${filteredMatches.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        _selectedFilter,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Matches List
                if (otherMatches.isEmpty && (_selectedFilter != 'All' && _selectedFilter != 'Live'))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No matches found for "$_selectedFilter"',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...otherMatches.map((match) {
                    return MatchCard(
                      match: match,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailScreen(
                              matchId: match.id,
                              dataService: widget.dataService,
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveTickerNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'LIVE ENGINE: Real-time ball-by-ball updates active. Tap any match to explore scorecard & worm chart.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => widget.dataService.stepNextBall(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Text(
                '+1 Ball',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
    );
  }
}
