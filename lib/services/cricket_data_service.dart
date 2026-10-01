import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/scorecard_model.dart';
import '../models/commentary_model.dart';
import '../models/tournament_model.dart';
import '../models/news_model.dart';
import '../models/ranking_model.dart';
import '../theme/app_colors.dart';

class CricketDataService extends ChangeNotifier {
  late List<CricketMatch> _matches;
  Timer? _simulationTimer;
  bool _isAutoSimulating = true;
  double _simSpeed = 1.0; // 1.0x, 2.0x, 4.0x
  final Random _rng = Random();

  // Fan Poll
  String? _selectedPollOption;
  final Map<String, int> _pollVotes = {
    'India': 4520,
    'Australia': 2140,
    'England': 980,
    'South Africa': 1350,
  };

  CricketDataService() {
    _initializeData();
    _startSimulation();
  }

  List<CricketMatch> get matches => _matches;
  bool get isAutoSimulating => _isAutoSimulating;
  double get simSpeed => _simSpeed;
  String? get selectedPollOption => _selectedPollOption;
  Map<String, int> get pollVotes => _pollVotes;

  CricketMatch? getMatchById(String id) {
    try {
      return _matches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  CricketMatch get featuredMatch => _matches.first;

  void toggleAutoSimulation() {
    _isAutoSimulating = !_isAutoSimulating;
    if (_isAutoSimulating) {
      _startSimulation();
    } else {
      _simulationTimer?.cancel();
    }
    notifyListeners();
  }

  void setSimulationSpeed(double speed) {
    _simSpeed = speed;
    if (_isAutoSimulating) {
      _startSimulation();
    }
    notifyListeners();
  }

  void votePoll(String option) {
    if (_selectedPollOption != null) return;
    _selectedPollOption = option;
    _pollVotes[option] = (_pollVotes[option] ?? 0) + 1;
    notifyListeners();
  }

  void stepNextBall([String? matchId]) {
    final id = matchId ?? _matches.first.id;
    _simulateNextBallForMatch(id);
    notifyListeners();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    final intervalMs = (2800 / _simSpeed).round().clamp(500, 5000);
    _simulationTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _simulateNextBallForMatch(_matches.first.id);
      notifyListeners();
    });
  }

  void _simulateNextBallForMatch(String matchId) {
    final match = getMatchById(matchId);
    if (match == null || match.status != MatchStatus.live) return;

    final battingTeam = match.currentInningsIndex == 1 ? match.team1 : match.team2;
    final bowlingTeam = match.currentInningsIndex == 1 ? match.team2 : match.team1;
    final scorecard = match.currentInningsIndex == 1 ? match.innings1 : match.innings2;

    if (scorecard == null || match.striker == null || match.bowler == null) return;

    // Check if match reached target or 20 overs
    if (match.target != null && battingTeam.runs >= match.target!) {
      match.status = MatchStatus.completed;
      match.resultSummary = '${battingTeam.name} won by ${10 - battingTeam.wickets} wickets!';
      match.currentEquation = 'Match Finished • ${battingTeam.name} won!';
      _simulationTimer?.cancel();
      _isAutoSimulating = false;
      return;
    }

    final totalBalls = _oversToBalls(battingTeam.overs);
    if (totalBalls >= 120 || battingTeam.wickets >= 10) {
      match.status = MatchStatus.completed;
      if (match.target != null) {
        if (battingTeam.runs >= match.target!) {
          match.resultSummary = '${battingTeam.name} won by ${10 - battingTeam.wickets} wickets!';
        } else if (battingTeam.runs == match.target! - 1) {
          match.resultSummary = 'Match Tied! (Super Over awaits)';
        } else {
          final diff = (match.target! - 1) - battingTeam.runs;
          match.resultSummary = '${bowlingTeam.name} won by $diff runs!';
        }
      } else {
        match.resultSummary = 'Innings completed';
      }
      match.currentEquation = 'Match Finished • ${match.resultSummary}';
      _simulationTimer?.cancel();
      _isAutoSimulating = false;
      return;
    }

    // Weight probabilities for realistic death-overs drama:
    // 0: 20%, 1: 30%, 2: 15%, 3: 2%, 4: 16%, 6: 10%, W: 7%
    final roll = _rng.nextInt(100);
    String ballOutcome;
    int runsScored = 0;
    bool isWicket = false;
    bool isBoundary = false;
    bool isSix = false;

    if (roll < 20) {
      ballOutcome = '0';
      runsScored = 0;
    } else if (roll < 50) {
      ballOutcome = '1';
      runsScored = 1;
    } else if (roll < 65) {
      ballOutcome = '2';
      runsScored = 2;
    } else if (roll < 67) {
      ballOutcome = '3';
      runsScored = 3;
    } else if (roll < 83) {
      ballOutcome = '4';
      runsScored = 4;
      isBoundary = true;
    } else if (roll < 93) {
      ballOutcome = '6';
      runsScored = 6;
      isSix = true;
    } else {
      ballOutcome = 'W';
      runsScored = 0;
      isWicket = true;
    }

    // Advance over count
    final curFullOvers = battingTeam.overs.floor();
    final curBallInOver = ((battingTeam.overs - curFullOvers) * 10).round();
    int nextFullOvers = curFullOvers;
    int nextBallInOver = curBallInOver + 1;
    bool overCompleted = false;

    if (nextBallInOver >= 6) {
      nextFullOvers += 1;
      nextBallInOver = 0;
      overCompleted = true;
    }

    final newOvers = nextFullOvers + (nextBallInOver * 0.1);
    battingTeam.overs = double.parse(newOvers.toStringAsFixed(1));
    scorecard.overs = battingTeam.overs;

    // Update runs & wickets
    battingTeam.runs += runsScored;
    scorecard.runs = battingTeam.runs;
    match.partnershipRuns += runsScored;
    match.partnershipBalls += 1;

    // Update striker
    match.striker!.runs += runsScored;
    match.striker!.balls += 1;
    if (isBoundary) match.striker!.fours += 1;
    if (isSix) match.striker!.sixes += 1;

    // Update bowler
    match.bowler!.runs += runsScored;
    final bFull = match.bowler!.overs.floor();
    final bBall = ((match.bowler!.overs - bFull) * 10).round() + 1;
    if (bBall >= 6) {
      match.bowler!.overs = (bFull + 1).toDouble();
    } else {
      match.bowler!.overs = double.parse((bFull + (bBall * 0.1)).toStringAsFixed(1));
    }

    if (runsScored == 0 && !isWicket) {
      match.bowler!.dots += 1;
    }

    // Generate ball commentary
    final overBallStr = '$curFullOvers.${curBallInOver + 1}';
    String commTitle;
    String commDesc;

    if (isWicket) {
      battingTeam.wickets += 1;
      scorecard.wickets = battingTeam.wickets;
      match.bowler!.wickets += 1;
      match.striker!.isOut = true;
      match.striker!.dismissal = 'c ${_getFielderName(bowlingTeam.shortCode)} b ${match.bowler!.name}';
      match.striker!.bowler = match.bowler!.name;

      scorecard.fallOfWickets.add(
        FallOfWicket(
          wicketNumber: battingTeam.wickets,
          score: battingTeam.runs,
          over: overBallStr,
          batter: match.striker!.name,
        ),
      );

      commTitle = 'WICKET! ${match.striker!.name} holes out!';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, OUT! Big swing across the line, gets a thick edge straight down the throat of deep mid-wicket. Crucial twist in the chase!';

      // Bring in next batter from bench
      final nextBatterName = _getNextBatterName(battingTeam.shortCode, battingTeam.wickets);
      final newBatter = BatterScore(
        name: nextBatterName,
        runs: 0,
        balls: 0,
        fours: 0,
        sixes: 0,
        isStriker: true,
      );
      scorecard.batters.add(newBatter);
      match.striker = newBatter;
      match.partnershipRuns = 0;
      match.partnershipBalls = 0;
    } else if (isSix) {
      commTitle = 'SIX! Monster hit into the second tier!';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, SIX! In the slot and launched high and handsome over wide long-on. 94 meters of pure authority!';
    } else if (isBoundary) {
      commTitle = 'FOUR! Pierces the gap with precision!';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, FOUR! Leans into a crisp cover drive, beat mid-off and beats sweeping sweeper with sheer timing.';
    } else if (runsScored == 0) {
      commTitle = 'Dot ball, pinpoint yorker!';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, no run. Fast toe-crusher at 144kph, jammed out back to the bowler.';
    } else if (runsScored == 1) {
      commTitle = 'Single taken to long-off';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, 1 run, worked gently towards deep midwicket, sharp sprint across.';
    } else if (runsScored == 2) {
      commTitle = 'Brilliant running between the wickets, 2 runs';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, 2 runs, nudged into the vacant pocket at deep square leg, they push hard and turn back comfortably for the brace.';
    } else {
      commTitle = 'Three runs taken';
      commDesc = '${match.bowler!.name} to ${match.striker!.name}, 3 runs, cut behind point, chased down by third man right on the rope.';
    }

    // Add commentary item to front of list
    match.commentary.insert(
      0,
      CommentaryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        over: overBallStr,
        outcome: ballOutcome,
        title: commTitle,
        description: commDesc,
        bowler: match.bowler!.name,
        batsman: match.striker!.name,
        timestamp: DateTime.now(),
        isBoundary: isBoundary,
        isSix: isSix,
        isWicket: isWicket,
      ),
    );

    // Update recent balls
    match.recentBalls.insert(0, ballOutcome);
    if (match.recentBalls.length > 8) {
      match.recentBalls.removeLast();
    }

    // Strike rotation on odd runs (1 or 3)
    if (!isWicket && (runsScored == 1 || runsScored == 3)) {
      _swapStrikers(match);
    }

    // Over completed logic
    if (overCompleted) {
      _swapStrikers(match);
      _rotateBowler(match, bowlingTeam);

      // Over summary commentary
      final overRuns = battingTeam.runs - (match.runProgressionTeam2.isNotEmpty ? match.runProgressionTeam2.last.toInt() : 0);
      match.commentary.insert(
        0,
        CommentaryItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_ov',
          over: '$nextFullOvers.0',
          outcome: 'OV',
          title: 'End of Over $nextFullOvers',
          description: '${battingTeam.shortCode}: ${battingTeam.runs}/${battingTeam.wickets} • $overRuns runs conceded in the over.',
          bowler: match.bowler!.name,
          batsman: match.striker!.name,
          timestamp: DateTime.now(),
          isOverSummary: true,
          overSummaryRuns: '$overRuns runs',
        ),
      );

      // Update worm progression
      match.runProgressionTeam2.add(battingTeam.runs.toDouble());
    }

    // Recalculate target equation
    if (match.target != null) {
      match.requiredRuns = (match.target! - battingTeam.runs).clamp(0, 999);
      final ballsBowled = _oversToBalls(battingTeam.overs);
      match.ballsRemaining = (120 - ballsBowled).clamp(0, 120);

      if (match.requiredRuns! <= 0) {
        match.status = MatchStatus.completed;
        match.resultSummary = '${battingTeam.name} won by ${10 - battingTeam.wickets} wickets!';
        match.currentEquation = 'Match Finished • ${battingTeam.name} won!';
      } else if (match.ballsRemaining! <= 0) {
        match.status = MatchStatus.completed;
        match.resultSummary = '${bowlingTeam.name} won by ${match.requiredRuns!} runs!';
        match.currentEquation = 'Match Finished • ${bowlingTeam.name} won!';
      } else {
        match.currentEquation = 'Need ${match.requiredRuns} runs in ${match.ballsRemaining} balls';
      }

      // Dynamic win probability calculation
      final rrr = match.requiredRunRate;
      if (rrr > 18.0) {
        match.winProbabilityTeam2 = 12.0;
        match.winProbabilityTeam1 = 88.0;
      } else if (rrr > 14.0) {
        match.winProbabilityTeam2 = 28.0;
        match.winProbabilityTeam1 = 72.0;
      } else if (rrr > 10.0) {
        match.winProbabilityTeam2 = 45.0;
        match.winProbabilityTeam1 = 55.0;
      } else if (rrr > 7.0) {
        match.winProbabilityTeam2 = 68.0;
        match.winProbabilityTeam1 = 32.0;
      } else {
        match.winProbabilityTeam2 = 85.0;
        match.winProbabilityTeam1 = 15.0;
      }
    }
  }

  void _swapStrikers(CricketMatch match) {
    if (match.striker == null || match.nonStriker == null) return;
    final temp = match.striker!;
    match.striker = match.nonStriker;
    match.nonStriker = temp;
    match.striker!.isStriker = true;
    match.nonStriker!.isStriker = false;
  }

  void _rotateBowler(CricketMatch match, MatchTeam bowlingTeam) {
    final scorecard = match.currentInningsIndex == 1 ? match.innings1 : match.innings2;
    if (scorecard == null) return;

    final pool = scorecard.bowlers;
    final curName = match.bowler?.name;
    final candidates = pool.where((b) => b.name != curName && b.overs < 4.0).toList();

    if (candidates.isNotEmpty) {
      match.bowler = candidates[_rng.nextInt(candidates.length)];
    }
  }

  String _getFielderName(String teamCode) {
    if (teamCode == 'AUS') {
      final fielders = ['Glenn Maxwell', 'David Warner', 'Steve Smith', 'Travis Head', 'Josh Inglis'];
      return fielders[_rng.nextInt(fielders.length)];
    }
    return 'Fielder';
  }

  String _getNextBatterName(String teamCode, int wicketNumber) {
    if (teamCode == 'IND') {
      final order = [
        'Hardik Pandya',
        'Ravindra Jadeja',
        'Axar Patel',
        'Kuldeep Yadav',
        'Jasprit Bumrah',
        'Arshdeep Singh',
        'Mohammed Siraj',
      ];
      final index = (wicketNumber - 4).clamp(0, order.length - 1);
      return order[index];
    }
    return 'Batter $wicketNumber';
  }

  int _oversToBalls(double overs) {
    final full = overs.floor();
    final balls = ((overs - full) * 10).round();
    return (full * 6) + balls;
  }

  // Standings data
  List<TournamentGroup> get worldCupStandings => [
    TournamentGroup(
      groupName: 'Super 8 - Group 1',
      standings: [
        PointsTableEntry(
          rank: 1,
          teamName: 'India',
          shortCode: 'IND',
          flagEmoji: '🇮🇳',
          played: 3,
          won: 3,
          lost: 0,
          netRunRate: 2.145,
          points: 6,
          formGuide: ['W', 'W', 'W'],
          isQualified: true,
        ),
        PointsTableEntry(
          rank: 2,
          teamName: 'Australia',
          shortCode: 'AUS',
          flagEmoji: '🇦🇺',
          played: 3,
          won: 2,
          lost: 1,
          netRunRate: 0.892,
          points: 4,
          formGuide: ['W', 'L', 'W'],
          isQualified: true,
        ),
        PointsTableEntry(
          rank: 3,
          teamName: 'Afghanistan',
          shortCode: 'AFG',
          flagEmoji: '🇦🇫',
          played: 3,
          won: 1,
          lost: 2,
          netRunRate: -0.412,
          points: 2,
          formGuide: ['L', 'W', 'L'],
        ),
        PointsTableEntry(
          rank: 4,
          teamName: 'Bangladesh',
          shortCode: 'BAN',
          flagEmoji: '🇧🇩',
          played: 3,
          won: 0,
          lost: 3,
          netRunRate: -2.389,
          points: 0,
          formGuide: ['L', 'L', 'L'],
        ),
      ],
    ),
    TournamentGroup(
      groupName: 'Super 8 - Group 2',
      standings: [
        PointsTableEntry(
          rank: 1,
          teamName: 'South Africa',
          shortCode: 'SA',
          flagEmoji: '🇿🇦',
          played: 3,
          won: 3,
          lost: 0,
          netRunRate: 1.455,
          points: 6,
          formGuide: ['W', 'W', 'W'],
          isQualified: true,
        ),
        PointsTableEntry(
          rank: 2,
          teamName: 'England',
          shortCode: 'ENG',
          flagEmoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
          played: 3,
          won: 2,
          lost: 1,
          netRunRate: 0.631,
          points: 4,
          formGuide: ['L', 'W', 'W'],
          isQualified: true,
        ),
        PointsTableEntry(
          rank: 3,
          teamName: 'West Indies',
          shortCode: 'WI',
          flagEmoji: '🏝️',
          played: 3,
          won: 1,
          lost: 2,
          netRunRate: -0.198,
          points: 2,
          formGuide: ['W', 'L', 'L'],
        ),
        PointsTableEntry(
          rank: 4,
          teamName: 'USA',
          shortCode: 'USA',
          flagEmoji: '🇺🇸',
          played: 3,
          won: 0,
          lost: 3,
          netRunRate: -1.820,
          points: 0,
          formGuide: ['L', 'L', 'L'],
        ),
      ],
    ),
  ];

  // ICC Rankings Data
  List<PlayerRanking> get rankingsT20Batting => [
    PlayerRanking(rank: 1, name: 'Suryakumar Yadav', teamShort: 'IND', flagEmoji: '🇮🇳', rating: 861, pointsDiff: '+1', role: 'Batting', format: 'T20I'),
    PlayerRanking(rank: 2, name: 'Phil Salt', teamShort: 'ENG', flagEmoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', rating: 802, pointsDiff: '0', role: 'Batting', format: 'T20I'),
    PlayerRanking(rank: 3, name: 'Travis Head', teamShort: 'AUS', flagEmoji: '🇦🇺', rating: 788, pointsDiff: '+3', role: 'Batting', format: 'T20I'),
    PlayerRanking(rank: 4, name: 'Mohammad Rizwan', teamShort: 'PAK', flagEmoji: '🇵🇰', rating: 772, pointsDiff: '-1', role: 'Batting', format: 'T20I'),
    PlayerRanking(rank: 5, name: 'Babar Azam', teamShort: 'PAK', flagEmoji: '🇵🇰', rating: 755, pointsDiff: '-1', role: 'Batting', format: 'T20I'),
    PlayerRanking(rank: 6, name: 'Yashasvi Jaiswal', teamShort: 'IND', flagEmoji: '🇮🇳', rating: 748, pointsDiff: '+2', role: 'Batting', format: 'T20I'),
  ];

  List<PlayerRanking> get rankingsT20Bowling => [
    PlayerRanking(rank: 1, name: 'Adil Rashid', teamShort: 'ENG', flagEmoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', rating: 718, pointsDiff: '0', role: 'Bowling', format: 'T20I'),
    PlayerRanking(rank: 2, name: 'Jasprit Bumrah', teamShort: 'IND', flagEmoji: '🇮🇳', rating: 708, pointsDiff: '+4', role: 'Bowling', format: 'T20I'),
    PlayerRanking(rank: 3, name: 'Wanindu Hasaranga', teamShort: 'SL', flagEmoji: '🇱🇰', rating: 692, pointsDiff: '-1', role: 'Bowling', format: 'T20I'),
    PlayerRanking(rank: 4, name: 'Rashid Khan', teamShort: 'AFG', flagEmoji: '🇦🇫', rating: 684, pointsDiff: '0', role: 'Bowling', format: 'T20I'),
    PlayerRanking(rank: 5, name: 'Adam Zampa', teamShort: 'AUS', flagEmoji: '🇦🇺', rating: 676, pointsDiff: '+1', role: 'Bowling', format: 'T20I'),
    PlayerRanking(rank: 6, name: 'Anrich Nortje', teamShort: 'SA', flagEmoji: '🇿🇦', rating: 660, pointsDiff: '+2', role: 'Bowling', format: 'T20I'),
  ];

  // News list
  List<CricketNews> get cricketNews => [
    CricketNews(
      id: 'news_1',
      title: 'ICC T20 World Cup Final: India & Australia set for epic MCG showdown',
      summary: 'High stakes in Melbourne as defending champions face off with unheralded intensity and full house attendance of 90,000.',
      category: 'World Cup 2026',
      timeAgo: '12m ago',
      readTime: '3 min read',
      author: 'Harsha Bhogle',
      imageUrl: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&auto=format&fit=crop&q=80',
      likes: 890,
    ),
    CricketNews(
      id: 'news_2',
      title: 'Tactical Breakdown: How Bumrah\'s reverse-swing masterclass dismantled England',
      summary: 'An in-depth statistical analysis on pitch mapping, release speed, and seam angle during the penultimate death overs.',
      category: 'Analysis',
      timeAgo: '1h ago',
      readTime: '5 min read',
      author: 'Michael Atherton',
      imageUrl: 'https://images.unsplash.com/photo-1531415074868-036b107e775a?w=800&auto=format&fit=crop&q=80',
      likes: 642,
    ),
    CricketNews(
      id: 'news_3',
      title: 'IPL 2026 Mega Auction: Record bids anticipated for young pace sensations',
      summary: 'Franchises prepare blockbuster wallets with purse caps increased to ₹120 Crore per team ahead of next spring.',
      category: 'IPL Auction',
      timeAgo: '4h ago',
      readTime: '4 min read',
      author: 'Aakash Chopra',
      imageUrl: 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=800&auto=format&fit=crop&q=80',
      likes: 412,
    ),
  ];

  // DLS / Target Calculator tool logic
  Map<String, dynamic> calculateDlsTarget({
    required int team1Runs,
    required double team1Overs,
    required double revisedOvers,
    required int wicketsLostTeam2,
  }) {
    // Standard cricket Duckworth-Lewis resource table simplified curve
    final double t1Resource = (team1Overs / 20.0).clamp(0.1, 1.0);
    final double t2Resource = (revisedOvers / 20.0).clamp(0.1, 1.0) * (1.0 - (wicketsLostTeam2 * 0.07));
    final target = ((team1Runs * (t2Resource / t1Resource)) + 1).round();
    final parScore = (target - 1).clamp(0, 500);

    return {
      'target': target,
      'parScore': parScore,
      'requiredRunRate': revisedOvers > 0 ? (target / revisedOvers).toStringAsFixed(2) : '0.00',
    };
  }

  void _initializeData() {
    // 1. Featured Match: IND vs AUS (T20 World Cup Final)
    final indTeam = MatchTeam(
      name: 'India',
      shortCode: 'IND',
      flagEmoji: '🇮🇳',
      primaryColor: AppColors.indiaBlue,
      secondaryColor: AppColors.primary,
      runs: 168,
      wickets: 4,
      overs: 17.4,
      isBatting: true,
      inningsString: '168/4 (17.4)',
    );

    final ausTeam = MatchTeam(
      name: 'Australia',
      shortCode: 'AUS',
      flagEmoji: '🇦🇺',
      primaryColor: AppColors.ausGold,
      secondaryColor: AppColors.boundaryAmber,
      runs: 187,
      wickets: 6,
      overs: 20.0,
      isBatting: false,
      inningsString: '187/6 (20.0)',
    );

    final viratKohli = BatterScore(
      name: 'Virat Kohli',
      runs: 68,
      balls: 44,
      fours: 6,
      sixes: 2,
      isStriker: true,
    );

    final hardikPandya = BatterScore(
      name: 'Hardik Pandya',
      runs: 32,
      balls: 17,
      fours: 2,
      sixes: 2,
      isNonStriker: true,
    );

    final patCummins = BowlerScore(
      name: 'Pat Cummins',
      overs: 3.4,
      maidens: 0,
      runs: 36,
      wickets: 2,
      dots: 8,
    );

    final ausInnings = InningsScorecard(
      teamShort: 'AUS',
      teamName: 'Australia',
      runs: 187,
      wickets: 6,
      overs: 20.0,
      extras: InningsExtras(wides: 6, noBalls: 1, byes: 2, legByes: 3),
      batters: [
        BatterScore(name: 'Travis Head', dismissal: 'c Rohit b Bumrah', runs: 54, balls: 32, fours: 7, sixes: 2, isOut: true),
        BatterScore(name: 'David Warner', dismissal: 'b Arshdeep', runs: 28, balls: 20, fours: 3, sixes: 1, isOut: true),
        BatterScore(name: 'Mitchell Marsh (c)', dismissal: 'c Pant b Axar', runs: 37, balls: 24, fours: 4, sixes: 1, isOut: true),
        BatterScore(name: 'Glenn Maxwell', dismissal: 'b Kuldeep', runs: 21, balls: 14, fours: 1, sixes: 2, isOut: true),
        BatterScore(name: 'Marcus Stoinis', dismissal: 'c Jadeja b Bumrah', runs: 18, balls: 12, fours: 2, sixes: 0, isOut: true),
        BatterScore(name: 'Tim David', dismissal: 'not out', runs: 16, balls: 9, fours: 1, sixes: 1),
        BatterScore(name: 'Matthew Wade (wk)', dismissal: 'run out (Kohli)', runs: 5, balls: 4, fours: 0, sixes: 0, isOut: true),
        BatterScore(name: 'Pat Cummins', dismissal: 'not out', runs: 2, balls: 5, fours: 0, sixes: 0),
      ],
      bowlers: [
        BowlerScore(name: 'Arshdeep Singh', overs: 4.0, maidens: 0, runs: 38, wickets: 1, dots: 9),
        BowlerScore(name: 'Jasprit Bumrah', overs: 4.0, maidens: 0, runs: 22, wickets: 2, dots: 14),
        BowlerScore(name: 'Axar Patel', overs: 4.0, maidens: 0, runs: 34, wickets: 1, dots: 8),
        BowlerScore(name: 'Kuldeep Yadav', overs: 4.0, maidens: 0, runs: 39, wickets: 1, dots: 6),
        BowlerScore(name: 'Hardik Pandya', overs: 4.0, maidens: 0, runs: 46, wickets: 0, dots: 5),
      ],
      fallOfWickets: [
        FallOfWicket(wicketNumber: 1, score: 48, over: '4.5', batter: 'David Warner'),
        FallOfWicket(wicketNumber: 2, score: 92, over: '9.3', batter: 'Travis Head'),
        FallOfWicket(wicketNumber: 3, score: 124, over: '13.1', batter: 'Glenn Maxwell'),
        FallOfWicket(wicketNumber: 4, score: 146, over: '15.4', batter: 'Mitchell Marsh'),
        FallOfWicket(wicketNumber: 5, score: 169, over: '18.1', batter: 'Marcus Stoinis'),
        FallOfWicket(wicketNumber: 6, score: 182, over: '19.2', batter: 'Matthew Wade'),
      ],
    );

    final indInnings = InningsScorecard(
      teamShort: 'IND',
      teamName: 'India',
      runs: 168,
      wickets: 4,
      overs: 17.4,
      extras: InningsExtras(wides: 4, noBalls: 0, byes: 1, legByes: 2),
      batters: [
        BatterScore(name: 'Rohit Sharma (c)', dismissal: 'c Warner b Starc', runs: 24, balls: 14, fours: 3, sixes: 1, isOut: true),
        BatterScore(name: 'Virat Kohli', dismissal: 'not out', runs: 68, balls: 44, fours: 6, sixes: 2, isStriker: true),
        BatterScore(name: 'Rishabh Pant (wk)', dismissal: 'c Marsh b Zampa', runs: 18, balls: 13, fours: 2, sixes: 0, isOut: true),
        BatterScore(name: 'Suryakumar Yadav', dismissal: 'c Head b Cummins', runs: 22, balls: 12, fours: 2, sixes: 1, isOut: true),
        viratKohli,
        hardikPandya,
      ],
      bowlers: [
        BowlerScore(name: 'Mitchell Starc', overs: 3.0, maidens: 0, runs: 32, wickets: 1, dots: 7),
        BowlerScore(name: 'Josh Hazlewood', overs: 4.0, maidens: 0, runs: 28, wickets: 0, dots: 11),
        patCummins,
        BowlerScore(name: 'Adam Zampa', overs: 4.0, maidens: 0, runs: 39, wickets: 1, dots: 8),
        BowlerScore(name: 'Marcus Stoinis', overs: 3.0, maidens: 0, runs: 33, wickets: 0, dots: 4),
      ],
      fallOfWickets: [
        FallOfWicket(wicketNumber: 1, score: 32, over: '3.2', batter: 'Rohit Sharma'),
        FallOfWicket(wicketNumber: 2, score: 78, over: '8.4', batter: 'Rishabh Pant'),
        FallOfWicket(wicketNumber: 3, score: 118, over: '12.6', batter: 'Suryakumar Yadav'),
        FallOfWicket(wicketNumber: 4, score: 139, over: '15.1', batter: 'Shivam Dube'),
      ],
      didNotBat: ['Ravindra Jadeja', 'Axar Patel', 'Kuldeep Yadav', 'Jasprit Bumrah', 'Arshdeep Singh'],
    );

    final List<CommentaryItem> initialComm = [
      CommentaryItem(
        id: 'c1',
        over: '17.4',
        outcome: '4',
        title: 'FOUR! Sliced over backward point!',
        description: 'Pat Cummins to Virat Kohli, FOUR! Angled across wide outside off, Kohli opens the face of the willow and guides it past the diving backward point fielder to the fence!',
        bowler: 'Pat Cummins',
        batsman: 'Virat Kohli',
        timestamp: DateTime.now().subtract(const Duration(seconds: 4)),
        isBoundary: true,
      ),
      CommentaryItem(
        id: 'c2',
        over: '17.3',
        outcome: '2',
        title: 'Two runs, excellent sprint',
        description: 'Pat Cummins to Virat Kohli, 2 runs, clipped into the deep midwicket vacancy. Kohli turns on the jets and dives home with ease!',
        bowler: 'Pat Cummins',
        batsman: 'Virat Kohli',
        timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
      ),
      CommentaryItem(
        id: 'c3',
        over: '17.2',
        outcome: '6',
        title: 'SIX! Hardik goes big downtown!',
        description: 'Pat Cummins to Hardik Pandya, SIX! Right into the slot, Hardik clears his front leg and sends it flying into the Great Southern Stand!',
        bowler: 'Pat Cummins',
        batsman: 'Hardik Pandya',
        timestamp: DateTime.now().subtract(const Duration(seconds: 14)),
        isSix: true,
      ),
      CommentaryItem(
        id: 'c4',
        over: '17.1',
        outcome: '1',
        title: 'Single down to long-on',
        description: 'Pat Cummins to Virat Kohli, 1 run, back of length on middle, tucked off hips down to deep square leg for one.',
        bowler: 'Pat Cummins',
        batsman: 'Virat Kohli',
        timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      ),
    ];

    final indSquad = [
      PlayerSquadInfo(name: 'Rohit Sharma', role: 'Batter', isCaptain: true),
      PlayerSquadInfo(name: 'Virat Kohli', role: 'Batter'),
      PlayerSquadInfo(name: 'Rishabh Pant', role: 'Wicketkeeper', isKeeper: true),
      PlayerSquadInfo(name: 'Suryakumar Yadav', role: 'Batter'),
      PlayerSquadInfo(name: 'Shivam Dube', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Hardik Pandya', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Ravindra Jadeja', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Axar Patel', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Kuldeep Yadav', role: 'Bowler'),
      PlayerSquadInfo(name: 'Jasprit Bumrah', role: 'Bowler'),
      PlayerSquadInfo(name: 'Arshdeep Singh', role: 'Bowler'),
    ];

    final ausSquad = [
      PlayerSquadInfo(name: 'Travis Head', role: 'Batter'),
      PlayerSquadInfo(name: 'David Warner', role: 'Batter'),
      PlayerSquadInfo(name: 'Mitchell Marsh', role: 'All-rounder', isCaptain: true),
      PlayerSquadInfo(name: 'Glenn Maxwell', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Marcus Stoinis', role: 'All-rounder'),
      PlayerSquadInfo(name: 'Tim David', role: 'Batter'),
      PlayerSquadInfo(name: 'Matthew Wade', role: 'Wicketkeeper', isKeeper: true),
      PlayerSquadInfo(name: 'Pat Cummins', role: 'Bowler'),
      PlayerSquadInfo(name: 'Mitchell Starc', role: 'Bowler'),
      PlayerSquadInfo(name: 'Adam Zampa', role: 'Bowler'),
      PlayerSquadInfo(name: 'Josh Hazlewood', role: 'Bowler'),
    ];

    final match1 = CricketMatch(
      id: 'match_ind_aus',
      title: 'India vs Australia',
      series: 'ICC Men\'s T20 World Cup 2026',
      stage: 'Grand Final',
      matchType: MatchType.t20,
      venue: 'Melbourne Cricket Ground, Melbourne',
      dateStr: 'Today • 07:30 PM Local',
      pitchReport: 'Even bounce and carry. Good pace for batting with slight assistance for seamers under lights.',
      weather: '21°C • Clear skies • 55% Humidity',
      toss: 'India won the toss and elected to field first',
      status: MatchStatus.live,
      resultSummary: 'In Progress • India chasing 188',
      currentEquation: 'Need 20 runs in 14 balls',
      currentInningsIndex: 2,
      team1: ausTeam,
      team2: indTeam,
      target: 188,
      requiredRuns: 20,
      ballsRemaining: 14,
      recentBalls: ['4', '2', '6', '1', '0', '4'],
      striker: viratKohli,
      nonStriker: hardikPandya,
      bowler: patCummins,
      partnershipRuns: 29,
      partnershipBalls: 15,
      winProbabilityTeam1: 34.0,
      winProbabilityTeam2: 66.0,
      innings1: ausInnings,
      innings2: indInnings,
      commentary: initialComm,
      team1Squad: ausSquad,
      team2Squad: indSquad,
      runProgressionTeam1: [8, 19, 31, 44, 52, 65, 74, 82, 91, 102, 114, 122, 131, 142, 150, 158, 166, 174, 181, 187],
      runProgressionTeam2: [11, 24, 32, 42, 55, 68, 77, 85, 96, 107, 118, 126, 134, 142, 151, 160, 168],
    );

    // 2. Match 2: ENG vs SA (Super 8 Clash - Live)
    final engTeam = MatchTeam(
      name: 'England',
      shortCode: 'ENG',
      flagEmoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      primaryColor: AppColors.engRed,
      secondaryColor: Colors.blueAccent,
      runs: 164,
      wickets: 5,
      overs: 18.2,
      isBatting: true,
      inningsString: '164/5 (18.2)',
    );

    final saTeam = MatchTeam(
      name: 'South Africa',
      shortCode: 'SA',
      flagEmoji: '🇿🇦',
      primaryColor: AppColors.saGreen,
      secondaryColor: AppColors.boundaryAmber,
      runs: 163,
      wickets: 6,
      overs: 20.0,
      isBatting: false,
      inningsString: '163/6 (20.0)',
    );

    final match2 = CricketMatch(
      id: 'match_eng_sa',
      title: 'England vs South Africa',
      series: 'ICC Men\'s T20 World Cup 2026',
      stage: 'Super 8 - Match 11',
      matchType: MatchType.t20,
      venue: 'Kensington Oval, Bridgetown, Barbados',
      dateStr: 'Today • 03:00 PM Local',
      pitchReport: 'Dry surface offering grip for slower balls and spinners.',
      weather: '29°C • Sunny with breezy trade winds',
      toss: 'South Africa won the toss and elected to bat',
      status: MatchStatus.live,
      resultSummary: 'England need 0 runs in 10 balls to win',
      currentEquation: 'England need 0 runs to win',
      currentInningsIndex: 2,
      team1: saTeam,
      team2: engTeam,
      target: 164,
      requiredRuns: 0,
      ballsRemaining: 10,
      recentBalls: ['1', '4', '1', '0', '6', '1'],
      winProbabilityTeam1: 5.0,
      winProbabilityTeam2: 95.0,
      innings1: InningsScorecard(
        teamShort: 'SA',
        teamName: 'South Africa',
        runs: 163,
        wickets: 6,
        overs: 20.0,
        extras: InningsExtras(wides: 3, noBalls: 0, byes: 0, legByes: 2),
        batters: [
          BatterScore(name: 'Quinton de Kock (wk)', dismissal: 'c Buttler b Archer', runs: 65, balls: 38, fours: 4, sixes: 4, isOut: true),
          BatterScore(name: 'Reeza Hendricks', dismissal: 'b Curran', runs: 19, balls: 25, fours: 1, sixes: 0, isOut: true),
          BatterScore(name: 'Heinrich Klaasen', dismissal: 'c Rashid b Curran', runs: 34, balls: 22, fours: 2, sixes: 2, isOut: true),
          BatterScore(name: 'David Miller', dismissal: 'not out', runs: 28, balls: 18, fours: 2, sixes: 1),
        ],
        bowlers: [
          BowlerScore(name: 'Jofra Archer', overs: 4.0, maidens: 0, runs: 28, wickets: 2, dots: 10),
          BowlerScore(name: 'Sam Curran', overs: 4.0, maidens: 0, runs: 33, wickets: 2, dots: 7),
          BowlerScore(name: 'Adil Rashid', overs: 4.0, maidens: 0, runs: 24, wickets: 1, dots: 12),
        ],
        fallOfWickets: [],
      ),
      innings2: InningsScorecard(
        teamShort: 'ENG',
        teamName: 'England',
        runs: 164,
        wickets: 5,
        overs: 18.2,
        extras: InningsExtras(wides: 4, noBalls: 1, byes: 0, legByes: 1),
        batters: [
          BatterScore(name: 'Jos Buttler (c & wk)', dismissal: 'c de Kock b Rabada', runs: 42, balls: 27, fours: 5, sixes: 1, isOut: true),
          BatterScore(name: 'Phil Salt', dismissal: 'c Markram b Nortje', runs: 16, balls: 10, fours: 3, sixes: 0, isOut: true),
          BatterScore(name: 'Harry Brook', dismissal: 'not out', runs: 53, balls: 37, fours: 4, sixes: 2, isStriker: true),
          BatterScore(name: 'Liam Livingstone', dismissal: 'not out', runs: 33, balls: 17, fours: 2, sixes: 2, isNonStriker: true),
        ],
        bowlers: [
          BowlerScore(name: 'Kagiso Rabada', overs: 4.0, maidens: 0, runs: 32, wickets: 2, dots: 11),
          BowlerScore(name: 'Anrich Nortje', overs: 3.2, maidens: 0, runs: 35, wickets: 1, dots: 7),
          BowlerScore(name: 'Keshav Maharaj', overs: 4.0, maidens: 0, runs: 25, wickets: 1, dots: 9),
        ],
        fallOfWickets: [],
      ),
      commentary: [
        CommentaryItem(
          id: 'sa_c1',
          over: '18.2',
          outcome: '1',
          title: 'Scores Level!',
          description: 'Anrich Nortje to Harry Brook, 1 run. Full and outside off, squirted to deep point. England level the scores!',
          bowler: 'Anrich Nortje',
          batsman: 'Harry Brook',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ],
      team1Squad: [],
      team2Squad: [],
      runProgressionTeam1: [7, 16, 28, 39, 48, 59, 68, 76, 84, 94, 105, 112, 120, 131, 139, 145, 151, 158, 161, 163],
      runProgressionTeam2: [12, 22, 34, 45, 54, 61, 70, 78, 88, 97, 105, 115, 124, 135, 144, 152, 160, 164],
    );

    // 3. Match 3: CSK vs MI (IPL El Clasico - Live)
    final cskTeam = MatchTeam(
      name: 'Chennai Super Kings',
      shortCode: 'CSK',
      flagEmoji: '🦁',
      primaryColor: AppColors.cskYellow,
      secondaryColor: Colors.orange,
      runs: 198,
      wickets: 5,
      overs: 19.1,
      isBatting: true,
      inningsString: '198/5 (19.1)',
    );

    final miTeam = MatchTeam(
      name: 'Mumbai Indians',
      shortCode: 'MI',
      flagEmoji: '⚡',
      primaryColor: AppColors.miBlue,
      secondaryColor: AppColors.boundaryAmber,
      runs: 206,
      wickets: 7,
      overs: 20.0,
      isBatting: false,
      inningsString: '206/7 (20.0)',
    );

    final match3 = CricketMatch(
      id: 'match_csk_mi',
      title: 'CSK vs MI',
      series: 'Indian Premier League 2026',
      stage: 'League Match 34',
      matchType: MatchType.t20,
      venue: 'Wankhede Stadium, Mumbai',
      dateStr: 'Tonight • 07:30 PM IST',
      pitchReport: 'Batting paradise with true bounce and dew factor in 2nd half.',
      weather: '28°C • Coastal Breeze • High Dew',
      toss: 'CSK won the toss and elected to field',
      status: MatchStatus.live,
      resultSummary: 'CSK need 9 runs in 5 balls',
      currentEquation: 'Need 9 runs in 5 balls',
      currentInningsIndex: 2,
      team1: miTeam,
      team2: cskTeam,
      target: 207,
      requiredRuns: 9,
      ballsRemaining: 5,
      recentBalls: ['6', '1', '4', 'W', '2', '6'],
      winProbabilityTeam1: 42.0,
      winProbabilityTeam2: 58.0,
      innings1: InningsScorecard(
        teamShort: 'MI',
        teamName: 'Mumbai Indians',
        runs: 206,
        wickets: 7,
        overs: 20.0,
        extras: InningsExtras(wides: 5, noBalls: 1),
        batters: [
          BatterScore(name: 'Rohit Sharma', runs: 58, balls: 31, fours: 6, sixes: 3, isOut: true),
          BatterScore(name: 'Ishan Kishan (wk)', runs: 32, balls: 18, fours: 4, sixes: 1, isOut: true),
          BatterScore(name: 'Suryakumar Yadav', runs: 62, balls: 30, fours: 5, sixes: 4, isOut: true),
        ],
        bowlers: [
          BowlerScore(name: 'Matheesha Pathirana', overs: 4.0, maidens: 0, runs: 32, wickets: 3),
        ],
        fallOfWickets: [],
      ),
      innings2: InningsScorecard(
        teamShort: 'CSK',
        teamName: 'Chennai Super Kings',
        runs: 198,
        wickets: 5,
        overs: 19.1,
        extras: InningsExtras(wides: 3, noBalls: 0),
        batters: [
          BatterScore(name: 'Ruturaj Gaikwad (c)', runs: 74, balls: 45, fours: 8, sixes: 3, isOut: true),
          BatterScore(name: 'Shivam Dube', runs: 48, balls: 22, fours: 2, sixes: 5, isOut: true),
          BatterScore(name: 'MS Dhoni', runs: 20, balls: 6, fours: 1, sixes: 2, isStriker: true),
        ],
        bowlers: [
          BowlerScore(name: 'Jasprit Bumrah', overs: 4.0, maidens: 0, runs: 24, wickets: 2),
        ],
        fallOfWickets: [],
      ),
      commentary: [
        CommentaryItem(
          id: 'csk_1',
          over: '19.1',
          outcome: '6',
          title: 'SIX! THALA DHONI SPECIAL!',
          description: 'Hardik Pandya to MS Dhoni, SIX! Back of a length, Dhoni rocks back and hoicks it over deep square leg into the crowd! Roof has come off at Wankhede!',
          bowler: 'Hardik Pandya',
          batsman: 'MS Dhoni',
          timestamp: DateTime.now().subtract(const Duration(seconds: 40)),
          isSix: true,
        ),
      ],
      team1Squad: [],
      team2Squad: [],
      runProgressionTeam1: [10, 22, 36, 48, 62, 74, 85, 98, 112, 124, 136, 149, 161, 172, 184, 192, 206],
      runProgressionTeam2: [12, 26, 38, 52, 66, 78, 90, 104, 118, 130, 145, 158, 170, 182, 198],
    );

    // 4. Match 4: PAK vs NZ (Upcoming)
    final pakTeam = MatchTeam(
      name: 'Pakistan',
      shortCode: 'PAK',
      flagEmoji: '🇵🇰',
      primaryColor: AppColors.pakGreen,
      secondaryColor: AppColors.primary,
    );

    final nzTeam = MatchTeam(
      name: 'New Zealand',
      shortCode: 'NZ',
      flagEmoji: '🇳🇿',
      primaryColor: AppColors.nzBlack,
      secondaryColor: Colors.tealAccent,
    );

    final match4 = CricketMatch(
      id: 'match_pak_nz',
      title: 'Pakistan vs New Zealand',
      series: 'ICC Men\'s T20 World Cup 2026',
      stage: 'Semi Final 2',
      matchType: MatchType.t20,
      venue: 'Eden Gardens, Kolkata',
      dateStr: 'Tomorrow • 07:00 PM IST',
      pitchReport: 'Traditional black soil pitch. Expect high scoring with spinners into the game in middle overs.',
      weather: '26°C • Clear night',
      toss: 'Toss scheduled at 06:30 PM IST',
      status: MatchStatus.upcoming,
      resultSummary: 'Match starts at 07:00 PM IST',
      currentEquation: 'Starts in 18 hrs 40 mins',
      team1: pakTeam,
      team2: nzTeam,
      recentBalls: [],
      innings1: InningsScorecard(
        teamShort: 'PAK',
        teamName: 'Pakistan',
        runs: 0,
        wickets: 0,
        overs: 0,
        extras: InningsExtras(),
        batters: [],
        bowlers: [],
        fallOfWickets: [],
      ),
      commentary: [],
      team1Squad: [
        PlayerSquadInfo(name: 'Babar Azam', role: 'Batter', isCaptain: true),
        PlayerSquadInfo(name: 'Mohammad Rizwan', role: 'Wicketkeeper', isKeeper: true),
        PlayerSquadInfo(name: 'Shaheen Afridi', role: 'Bowler'),
        PlayerSquadInfo(name: 'Naseem Shah', role: 'Bowler'),
        PlayerSquadInfo(name: 'Haris Rauf', role: 'Bowler'),
      ],
      team2Squad: [
        PlayerSquadInfo(name: 'Kane Williamson', role: 'Batter', isCaptain: true),
        PlayerSquadInfo(name: 'Devon Conway', role: 'Wicketkeeper', isKeeper: true),
        PlayerSquadInfo(name: 'Trent Boult', role: 'Bowler'),
        PlayerSquadInfo(name: 'Mitchell Santner', role: 'All-rounder'),
      ],
      runProgressionTeam1: [],
      runProgressionTeam2: [],
    );

    // 5. Match 5: WI vs SL (Completed)
    final wiTeam = MatchTeam(
      name: 'West Indies',
      shortCode: 'WI',
      flagEmoji: '🏝️',
      primaryColor: const Color(0xFF7F1D1D),
      secondaryColor: AppColors.boundaryAmber,
      runs: 178,
      wickets: 6,
      overs: 18.4,
      inningsString: '178/6 (18.4)',
    );

    final slTeam = MatchTeam(
      name: 'Sri Lanka',
      shortCode: 'SL',
      flagEmoji: '🇱🇰',
      primaryColor: const Color(0xFF1E3A8A),
      secondaryColor: AppColors.boundaryAmber,
      runs: 174,
      wickets: 8,
      overs: 20.0,
      inningsString: '174/8 (20.0)',
    );

    final match5 = CricketMatch(
      id: 'match_wi_sl',
      title: 'West Indies vs Sri Lanka',
      series: 'West Indies tour of Sri Lanka',
      stage: '3rd T20I',
      matchType: MatchType.t20,
      venue: 'R. Premadasa Stadium, Colombo',
      dateStr: 'Yesterday',
      pitchReport: 'Sluggish surface with true turn for spinners.',
      weather: '27°C • Humid',
      toss: 'West Indies won the toss and elected to field',
      status: MatchStatus.completed,
      resultSummary: 'West Indies won by 4 wickets (8 balls left)',
      currentEquation: 'West Indies won by 4 wickets',
      currentInningsIndex: 2,
      team1: slTeam,
      team2: wiTeam,
      target: 175,
      requiredRuns: 0,
      ballsRemaining: 0,
      recentBalls: ['4', '6', '1', '4', '0', '6'],
      innings1: InningsScorecard(
        teamShort: 'SL',
        teamName: 'Sri Lanka',
        runs: 174,
        wickets: 8,
        overs: 20.0,
        extras: InningsExtras(wides: 5),
        batters: [
          BatterScore(name: 'Pathum Nissanka', runs: 58, balls: 38, fours: 6, sixes: 1, isOut: true),
          BatterScore(name: 'Kusal Mendis (wk)', runs: 42, balls: 29, fours: 4, sixes: 1, isOut: true),
        ],
        bowlers: [
          BowlerScore(name: 'Alzarri Joseph', overs: 4.0, maidens: 0, runs: 28, wickets: 3),
        ],
        fallOfWickets: [],
      ),
      innings2: InningsScorecard(
        teamShort: 'WI',
        teamName: 'West Indies',
        runs: 178,
        wickets: 6,
        overs: 18.4,
        extras: InningsExtras(wides: 4),
        batters: [
          BatterScore(name: 'Nicholas Pooran', runs: 65, balls: 34, fours: 5, sixes: 4, isOut: true),
          BatterScore(name: 'Rovman Powell (c)', runs: 42, balls: 21, fours: 3, sixes: 3, isOut: true),
        ],
        bowlers: [
          BowlerScore(name: 'Wanindu Hasaranga', overs: 4.0, maidens: 0, runs: 26, wickets: 2),
        ],
        fallOfWickets: [],
      ),
      commentary: [
        CommentaryItem(
          id: 'wi_win',
          over: '18.4',
          outcome: '6',
          title: 'SIX! Powell seals the series in style!',
          description: 'Rovman Powell smashes a towering six over wide long-on to clinch the series 2-1 for the Windies!',
          bowler: 'Matheesha Pathirana',
          batsman: 'Rovman Powell',
          timestamp: DateTime.now().subtract(const Duration(hours: 24)),
          isSix: true,
        ),
      ],
      team1Squad: [],
      team2Squad: [],
      runProgressionTeam1: [8, 18, 30, 42, 55, 68, 79, 90, 102, 114, 125, 136, 146, 156, 165, 174],
      runProgressionTeam2: [12, 24, 38, 52, 65, 78, 92, 105, 120, 132, 145, 158, 168, 178],
    );

    _matches = [match1, match2, match3, match4, match5];
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
