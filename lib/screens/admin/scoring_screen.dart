import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/score_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/current_over.dart';
import '../../widgets/player_card.dart';
import '../../widgets/score_card.dart';
import '../../widgets/scoring_button.dart';

class ScoringScreen extends StatefulWidget {
  final String matchId;

  const ScoringScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);

      final match = matchProvider.matches.firstWhere(
        (m) => m.id == widget.matchId,
        orElse: () => matchProvider.matches.first,
      );
      scoreProvider.setActiveMatch(match);
    });
  }

  void _showWicketDialog(ScoreProvider scoreProvider) {
    String wicketType = 'bowled';
    final batterController = TextEditingController(text: 'Batter Next');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.sports_cricket, color: AppColors.liveRed),
                  SizedBox(width: 8),
                  Text('RECORD WICKET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dismissal Type', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: wicketType,
                    dropdownColor: AppColors.cardElevated,
                    items: const [
                      DropdownMenuItem(value: 'bowled', child: Text('Bowled')),
                      DropdownMenuItem(value: 'caught', child: Text('Caught')),
                      DropdownMenuItem(value: 'lbw', child: Text('LBW')),
                      DropdownMenuItem(value: 'runOut', child: Text('Run Out')),
                      DropdownMenuItem(value: 'stumped', child: Text('Stumped')),
                    ],
                    onChanged: (val) => setDialogState(() => wicketType = val!),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.cardElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Next Incoming Batter', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: batterController,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.cardElevated,
                      hintText: 'Enter batter name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    scoreProvider.recordWicket(
                      wicketType: wicketType,
                      nextBatterName: batterController.text.trim().isNotEmpty
                          ? batterController.text.trim()
                          : null,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('CONFIRM WICKET', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeBowlerDialog(ScoreProvider scoreProvider) {
    final bowlerController = TextEditingController(text: 'Next Bowler');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('CHANGE BOWLER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          content: TextField(
            controller: bowlerController,
            decoration: InputDecoration(
              labelText: 'Bowler Name',
              isDense: true,
              filled: true,
              fillColor: AppColors.cardElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (bowlerController.text.trim().isNotEmpty) {
                  scoreProvider.changeBowler(bowlerController.text.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('UPDATE BOWLER', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _showEndInningsDialog(ScoreProvider scoreProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('CHANGE INNINGS?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'This will conclude the current innings, calculate the target score, and invert batting/bowling teams.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.boundaryAmber, foregroundColor: Colors.black),
            onPressed: () {
              scoreProvider.endInnings();
              Navigator.pop(context);
            },
            child: const Text('SWITCH INNINGS', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showEndMatchDialog(ScoreProvider scoreProvider) {
    final resultController = TextEditingController(text: 'Match Concluded');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('END MATCH', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: resultController,
          decoration: InputDecoration(
            labelText: 'Final Result Summary',
            isDense: true,
            filled: true,
            fillColor: AppColors.cardElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.liveRed, foregroundColor: Colors.white),
            onPressed: () {
              scoreProvider.endMatch(resultController.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match marked as completed!')),
              );
            },
            child: const Text('CONCLUDE MATCH', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final match = scoreProvider.currentMatch;

    if (match == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('LIVE SCORING CONSOLE')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          '${match.team1.shortCode} vs ${match.team2.shortCode} (Admin)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          // Undo Button
          IconButton(
            icon: Icon(
              Icons.undo,
              color: scoreProvider.canUndo ? AppColors.boundaryAmber : AppColors.textMuted,
            ),
            tooltip: 'Undo last ball',
            onPressed: scoreProvider.canUndo ? () => scoreProvider.undo() : null,
          ),
          PopupMenuButton<String>(
            color: AppColors.cardSurface,
            onSelected: (val) {
              if (val == 'bowler') _showChangeBowlerDialog(scoreProvider);
              if (val == 'innings') _showEndInningsDialog(scoreProvider);
              if (val == 'end') _showEndMatchDialog(scoreProvider);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'bowler', child: Text('Change Bowler')),
              const PopupMenuItem(value: 'innings', child: Text('Switch Innings')),
              const PopupMenuItem(value: 'end', child: Text('End Match')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live Score Summary Card
          ScoreCardWidget(match: match),

          const SizedBox(height: 14),

          // Batsmen & Bowler Cards
          PlayerCardWidget(
            striker: match.striker,
            nonStriker: match.nonStriker,
            bowler: match.bowler,
            onSwapStrikers: () => scoreProvider.swapStrikers(),
          ),

          const SizedBox(height: 14),

          // Current Over Deliveries Strip
          CurrentOverWidget(recentBalls: match.recentBalls),

          const SizedBox(height: 20),

          // Scoring Grid Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'LIVE SCORING CONTROLS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Instant Sync',
                style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scoring Grid (0, 1, 2, 3)
          Row(
            children: [
              Expanded(child: ScoringButton(label: '0', isLarge: true, onTap: () => scoreProvider.recordRuns(0))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: '1', isLarge: true, onTap: () => scoreProvider.recordRuns(1))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: '2', isLarge: true, onTap: () => scoreProvider.recordRuns(2))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: '3', isLarge: true, onTap: () => scoreProvider.recordRuns(3))),
            ],
          ),
          const SizedBox(height: 10),

          // Scoring Grid (4, 6, Wicket)
          Row(
            children: [
              Expanded(flex: 3, child: ScoringButton(label: '4', isLarge: true, onTap: () => scoreProvider.recordRuns(4))),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: ScoringButton(label: '6', isLarge: true, onTap: () => scoreProvider.recordRuns(6))),
              const SizedBox(width: 8),
              Expanded(flex: 4, child: ScoringButton(label: 'W', isLarge: true, onTap: () => _showWicketDialog(scoreProvider))),
            ],
          ),
          const SizedBox(height: 10),

          // Extras Grid (WD, NB, B, LB)
          Row(
            children: [
              Expanded(child: ScoringButton(label: 'WD', onTap: () => scoreProvider.recordExtra('wide'))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: 'NB', onTap: () => scoreProvider.recordExtra('noBall'))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: 'B', onTap: () => scoreProvider.recordExtra('bye'))),
              const SizedBox(width: 8),
              Expanded(child: ScoringButton(label: 'LB', onTap: () => scoreProvider.recordExtra('legBye'))),
            ],
          ),

          const SizedBox(height: 20),

          // Match Session Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showChangeBowlerDialog(scoreProvider),
                  icon: const Icon(Icons.sports_baseball, size: 16, color: AppColors.primary),
                  label: const Text('Change Bowler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.boundaryAmber),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showEndInningsDialog(scoreProvider),
                  icon: const Icon(Icons.sync_alt, size: 16, color: AppColors.boundaryAmber),
                  label: const Text('Switch Innings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.boundaryAmber)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
