import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import 'live_match_screen.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final completed = matchProvider.completedMatches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('MATCH ARCHIVE & RESULTS'),
      ),
      body: completed.isEmpty
          ? const Center(
              child: Text(
                'No completed matches in history yet.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completed.length,
              itemBuilder: (context, index) {
                final match = completed[index];
                return MatchCard(
                  match: match,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveMatchScreen(matchId: match.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
