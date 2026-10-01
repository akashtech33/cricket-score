import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/score_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/live_badge.dart';
import '../login_screen.dart';
import 'create_match_screen.dart';
import 'scoring_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
              'ADMIN DASHBOARD',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
            Text(
              'Signed in as: ${authProvider.user?.name ?? "Admin"}',
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats Banner
          _buildQuickStats(matchProvider),

          const SizedBox(height: 18),

          // "Create New Match" Prominent Action Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
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
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Start New Live Match',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Configure teams, toss, squads, and launch live scoring console',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
                    );
                  },
                  child: const Text('CREATE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR MANAGED MATCHES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              Text(
                '${matchProvider.matches.length} matches',
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Matches List
          if (matchProvider.matches.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Text('No matches created yet. Tap "CREATE" above to start scoring!'),
            )
          else
            ...matchProvider.matches.map((match) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: match.status.name == 'live'
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            match.series,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (match.status.name == 'live')
                          const LiveBadge(text: 'LIVE')
                        else
                          Text(
                            match.status.name.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(match.team1.flagEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${match.team1.name} vs ${match.team2.name}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${match.team1.shortCode}: ${match.team1.scoreDisplay}  •  ${match.team2.shortCode}: ${match.team2.scoreDisplay}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            match.currentEquation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.boundaryAmber, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);
                            scoreProvider.setActiveMatch(match);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScoringScreen(matchId: match.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.sports_cricket, size: 16),
                          label: const Text('OPEN SCORING', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickStats(MatchProvider matchProvider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LIVE NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text(
                  '${matchProvider.liveMatches.length}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  '${matchProvider.completedMatches.length}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
