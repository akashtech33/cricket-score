import 'package:flutter/material.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';

class FanZoneScreen extends StatefulWidget {
  final CricketDataService dataService;

  const FanZoneScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<FanZoneScreen> createState() => _FanZoneScreenState();
}

class _FanZoneScreenState extends State<FanZoneScreen> {
  // DLS Calculator State
  final _team1RunsController = TextEditingController(text: '185');
  final _team1OversController = TextEditingController(text: '20');
  final _revisedOversController = TextEditingController(text: '15');
  int _wicketsLost = 2;
  Map<String, dynamic>? _dlsResult;

  // Notification toggles
  bool _notifyWickets = true;
  bool _notifyBoundaries = false;
  bool _notifyResult = true;

  @override
  void initState() {
    super.initState();
    _calculateDls();
  }

  void _calculateDls() {
    final t1Runs = int.tryParse(_team1RunsController.text) ?? 185;
    final t1Overs = double.tryParse(_team1OversController.text) ?? 20.0;
    final revOvers = double.tryParse(_revisedOversController.text) ?? 15.0;

    setState(() {
      _dlsResult = widget.dataService.calculateDlsTarget(
        team1Runs: t1Runs,
        team1Overs: t1Overs,
        revisedOvers: revOvers,
        wicketsLostTeam2: _wicketsLost,
      );
    });
  }

  @override
  void dispose() {
    _team1RunsController.dispose();
    _team1OversController.dispose();
    _revisedOversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('FAN ZONE & UTILITIES'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Live Fan Poll Card
              _buildPollCard(),

              const SizedBox(height: 20),

              // 2. DLS / Rain Target Calculator
              _buildDlsCalculatorCard(),

              const SizedBox(height: 20),

              // 3. Cricket Trivia & Fun Facts
              _buildTriviaCard(),

              const SizedBox(height: 20),

              // 4. Alert Preferences
              _buildAlertPreferencesCard(),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollCard() {
    final votes = widget.dataService.pollVotes;
    final totalVotes = votes.values.fold(0, (sum, count) => sum + count);
    final selected = widget.dataService.selectedPollOption;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
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
                  Icon(Icons.how_to_vote_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'FAN PREDICTOR POLL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '$totalVotes votes',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Who will lift the ICC Men\'s T20 World Cup 2026 trophy?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),

          // Options
          ...votes.keys.map((option) {
            final count = votes[option] ?? 0;
            final percent = totalVotes > 0 ? (count / totalVotes) * 100 : 0.0;
            final isChosen = selected == option;

            return GestureDetector(
              onTap: () => widget.dataService.votePoll(option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isChosen ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChosen ? AppColors.primary : AppColors.border,
                    width: isChosen ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isChosen)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                              ),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isChosen ? FontWeight.w800 : FontWeight.w600,
                                color: isChosen ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isChosen ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100.0,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isChosen ? AppColors.primary : AppColors.borderLight,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDlsCalculatorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cloud_sync_outlined, color: AppColors.boundaryAmber, size: 20),
              SizedBox(width: 8),
              Text(
                'DLS / TARGET CALCULATOR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.boundaryAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Calculate rain-revised target score and required run rates.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Inputs
          Row(
            children: [
              Expanded(
                child: _buildCalcTextField(
                  controller: _team1RunsController,
                  label: 'Team 1 Score',
                  onChanged: (_) => _calculateDls(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCalcTextField(
                  controller: _team1OversController,
                  label: 'Team 1 Overs',
                  onChanged: (_) => _calculateDls(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCalcTextField(
                  controller: _revisedOversController,
                  label: 'Revised Overs',
                  onChanged: (_) => _calculateDls(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wickets Lost', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _wicketsLost,
                          dropdownColor: AppColors.cardElevated,
                          isExpanded: true,
                          items: List.generate(10, (i) => i).map((w) {
                            return DropdownMenuItem(value: w, child: Text('$w wkt'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _wicketsLost = val;
                              });
                              _calculateDls();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Result Display Banner
          if (_dlsResult != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('REVISED TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        '${_dlsResult!['target']}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 35, color: AppColors.border),
                  Column(
                    children: [
                      const Text('PAR SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        '${_dlsResult!['parScore']}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 35, color: AppColors.border),
                  Column(
                    children: [
                      const Text('REQ. RR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        '${_dlsResult!['requiredRunRate']}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalcTextField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.cardElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTriviaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: AppColors.boundaryAmber, size: 20),
              SizedBox(width: 8),
              Text(
                'CRICKET TRIVIA & RECORD WATCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.boundaryAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTriviaItem('⚡ Fastest T20 Century', 'Chris Gayle off 30 balls (RCB vs PWI, 2013)'),
          const Divider(color: AppColors.border, height: 16),
          _buildTriviaItem('🎯 Best T20 Bowling Spell', 'Deepak Chahar 6/7 vs Bangladesh'),
          const Divider(color: AppColors.border, height: 16),
          _buildTriviaItem('🏆 Most T20 WC Titles', 'West Indies & England (2 titles each)'),
        ],
      ),
    );
  }

  Widget _buildTriviaItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildAlertPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'MATCH ALERTS & NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Wickets Fall Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Get instant notification whenever a wicket falls', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _notifyWickets,
            onChanged: (val) => setState(() => _notifyWickets = val),
          ),
          const Divider(color: AppColors.border, height: 1),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Boundary & Milestone Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Alerts on 50s, 100s, and high-scoring overs', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _notifyBoundaries,
            onChanged: (val) => setState(() => _notifyBoundaries = val),
          ),
          const Divider(color: AppColors.border, height: 1),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Match Result Alert', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Full result summary and man of the match', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _notifyResult,
            onChanged: (val) => setState(() => _notifyResult = val),
          ),
        ],
      ),
    );
  }
}
