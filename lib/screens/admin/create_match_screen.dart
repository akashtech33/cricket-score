import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_model.dart';
import '../../models/scorecard_model.dart';
import '../../providers/match_provider.dart';
import '../../providers/score_provider.dart';
import '../../theme/app_colors.dart';
import 'scoring_screen.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(text: 'India vs Pakistan');
  final _seriesController = TextEditingController(text: 'ICC Champions Trophy 2026');
  final _venueController = TextEditingController(text: 'Dubai International Cricket Stadium');

  final _team1NameController = TextEditingController(text: 'India');
  final _team1CodeController = TextEditingController(text: 'IND');
  final _team2NameController = TextEditingController(text: 'Pakistan');
  final _team2CodeController = TextEditingController(text: 'PAK');

  final _oversController = TextEditingController(text: '20');
  final _strikerController = TextEditingController(text: 'Rohit Sharma');
  final _nonStrikerController = TextEditingController(text: 'Shubman Gill');
  final _bowlerController = TextEditingController(text: 'Shaheen Afridi');

  String _tossWinner = 'Team 1';
  String _tossDecision = 'Bat';
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _seriesController.dispose();
    _venueController.dispose();
    _team1NameController.dispose();
    _team1CodeController.dispose();
    _team2NameController.dispose();
    _team2CodeController.dispose();
    _oversController.dispose();
    _strikerController.dispose();
    _nonStrikerController.dispose();
    _bowlerController.dispose();
    super.dispose();
  }

  void _createAndStart() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);

    final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}';

    final team1IsBatting = (_tossWinner == 'Team 1' && _tossDecision == 'Bat') ||
        (_tossWinner == 'Team 2' && _tossDecision == 'Bowl');

    final team1 = MatchTeam(
      name: _team1NameController.text.trim(),
      shortCode: _team1CodeController.text.trim().toUpperCase(),
      flagEmoji: '🇮🇳',
      primaryColor: AppColors.indiaBlue,
      secondaryColor: AppColors.primary,
      runs: 0,
      wickets: 0,
      overs: 0.0,
      isBatting: team1IsBatting,
    );

    final team2 = MatchTeam(
      name: _team2NameController.text.trim(),
      shortCode: _team2CodeController.text.trim().toUpperCase(),
      flagEmoji: '🇵🇰',
      primaryColor: AppColors.pakGreen,
      secondaryColor: AppColors.secondary,
      runs: 0,
      wickets: 0,
      overs: 0.0,
      isBatting: !team1IsBatting,
    );

    final striker = BatterScore(
      name: _strikerController.text.trim(),
      runs: 0,
      balls: 0,
      fours: 0,
      sixes: 0,
      isStriker: true,
    );

    final nonStriker = BatterScore(
      name: _nonStrikerController.text.trim(),
      runs: 0,
      balls: 0,
      fours: 0,
      sixes: 0,
      isNonStriker: true,
    );

    final bowler = BowlerScore(
      name: _bowlerController.text.trim(),
      overs: 0,
      maidens: 0,
      runs: 0,
      wickets: 0,
    );

    final battingTeam = team1IsBatting ? team1 : team2;

    final innings1 = InningsScorecard(
      teamShort: battingTeam.shortCode,
      teamName: battingTeam.name,
      runs: 0,
      wickets: 0,
      overs: 0.0,
      extras: InningsExtras(),
      batters: [striker, nonStriker],
      bowlers: [bowler],
      fallOfWickets: [],
    );

    final tossWinnerName = _tossWinner == 'Team 1' ? team1.name : team2.name;
    final tossText = '$tossWinnerName won the toss and elected to ${_tossDecision.toLowerCase()} first';

    final match = CricketMatch(
      id: matchId,
      title: '${team1.name} vs ${team2.name}',
      series: _seriesController.text.trim(),
      stage: 'Group Match',
      matchType: MatchType.t20,
      venue: _venueController.text.trim(),
      dateStr: 'Live Today',
      pitchReport: 'Fresh pitch with good carry and true bounce.',
      weather: '27°C • Clear night',
      toss: tossText,
      status: MatchStatus.live,
      resultSummary: 'Match in progress',
      currentEquation: '1st Innings • 0/0 (0.0 ov)',
      team1: team1,
      team2: team2,
      recentBalls: [],
      striker: striker,
      nonStriker: nonStriker,
      bowler: bowler,
      innings1: innings1,
      commentary: [],
      team1Squad: [],
      team2Squad: [],
      runProgressionTeam1: [],
      runProgressionTeam2: [],
    );

    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);

    await matchProvider.createNewMatch(match);
    scoreProvider.setActiveMatch(match);

    setState(() => _isCreating = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ScoringScreen(matchId: match.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('CREATE NEW MATCH'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // General Info Card
            _buildSectionCard(
              title: 'MATCH INFORMATION',
              icon: Icons.info_outline,
              children: [
                _buildTextField(_titleController, 'Match Title', 'e.g. India vs Pakistan'),
                const SizedBox(height: 12),
                _buildTextField(_seriesController, 'Series / Tournament', 'e.g. ICC World Cup 2026'),
                const SizedBox(height: 12),
                _buildTextField(_venueController, 'Stadium / Venue', 'e.g. Eden Gardens, Kolkata'),
              ],
            ),

            const SizedBox(height: 16),

            // Teams Config
            _buildSectionCard(
              title: 'TEAMS CONFIGURATION',
              icon: Icons.groups_outlined,
              children: [
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_team1NameController, 'Team 1 Name', 'Team 1')),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildTextField(_team1CodeController, 'Short Code', 'T1')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_team2NameController, 'Team 2 Name', 'Team 2')),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildTextField(_team2CodeController, 'Short Code', 'T2')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_oversController, 'Overs Per Innings', '20', keyboardType: TextInputType.number),
              ],
            ),

            const SizedBox(height: 16),

            // Toss Section
            _buildSectionCard(
              title: 'TOSS DETAILS',
              icon: Icons.monetization_on_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Toss Winner', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _tossWinner,
                            dropdownColor: AppColors.cardSurface,
                            items: const [
                              DropdownMenuItem(value: 'Team 1', child: Text('Team 1')),
                              DropdownMenuItem(value: 'Team 2', child: Text('Team 2')),
                            ],
                            onChanged: (val) => setState(() => _tossWinner = val!),
                            decoration: _dropdownInputDecoration(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Elected To', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _tossDecision,
                            dropdownColor: AppColors.cardSurface,
                            items: const [
                              DropdownMenuItem(value: 'Bat', child: Text('Bat First')),
                              DropdownMenuItem(value: 'Bowl', child: Text('Bowl First')),
                            ],
                            onChanged: (val) => setState(() => _tossDecision = val!),
                            decoration: _dropdownInputDecoration(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Opening Players
            _buildSectionCard(
              title: 'OPENING BATTERS & BOWLER',
              icon: Icons.sports_cricket,
              children: [
                _buildTextField(_strikerController, 'Opening Striker (*)', 'Batter 1'),
                const SizedBox(height: 12),
                _buildTextField(_nonStrikerController, 'Non-Striker', 'Batter 2'),
                const SizedBox(height: 12),
                _buildTextField(_bowlerController, 'Opening Bowler', 'Bowler 1'),
              ],
            ),

            const SizedBox(height: 24),

            // Launch Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              onPressed: _isCreating ? null : _createAndStart,
              child: _isCreating
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text(
                      'START MATCH & OPEN SCORING',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.cardElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  InputDecoration _dropdownInputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.cardElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}
