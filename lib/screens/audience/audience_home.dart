import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/hero_match_card.dart';
import '../../widgets/match_card.dart';
import '../login_screen.dart';
import 'live_match_screen.dart';

class AudienceHomeScreen extends StatefulWidget {
  const AudienceHomeScreen({super.key});

  @override
  State<AudienceHomeScreen> createState() => _AudienceHomeScreenState();
}

class _AudienceHomeScreenState extends State<AudienceHomeScreen> with SingleTickerProviderStateMixin {
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
    final authProvider = Provider.of<AuthProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CRICPULSE LIVE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
            Text(
              'Audience Hub • ${authProvider.user?.name ?? "Cricket Fan"}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: 'LIVE (${matchProvider.liveMatches.length})'),
            Tab(text: 'UPCOMING (${matchProvider.upcomingMatches.length})'),
            Tab(text: 'COMPLETED (${matchProvider.completedMatches.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveMatchesTab(matchProvider),
          _buildMatchesList(matchProvider.upcomingMatches, 'No upcoming matches scheduled.'),
          _buildMatchesList(matchProvider.completedMatches, 'No completed match records yet.'),
        ],
      ),
    );
  }

  Widget _buildLiveMatchesTab(MatchProvider matchProvider) {
    final liveMatches = matchProvider.liveMatches;

    if (liveMatches.isEmpty) {
      return const Center(
        child: Text(
          'No live matches at the moment.\nAdmin will launch new matches shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
      );
    }

    final featured = liveMatches.first;
    final others = liveMatches.skip(1).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Featured Live Match Hero Card
        HeroMatchCard(
          match: featured,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveMatchScreen(matchId: featured.id)),
            );
          },
        ),

        if (others.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'OTHER LIVE FIXTURES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ...others.map((match) {
            return MatchCard(
              match: match,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiveMatchScreen(matchId: match.id)),
                );
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildMatchesList(List<CricketMatch> matches, String emptyMsg) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          match: match,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveMatchScreen(matchId: match.id)),
            );
          },
        );
      },
    );
  }
}
