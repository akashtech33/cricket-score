import '../models/match_model.dart';
import '../models/ball_model.dart';
import '../models/scorecard_model.dart';
import '../models/commentary_model.dart';
import '../utils/cricket_score_utils.dart';

class ScoreActionSnapshot {
  final CricketMatch matchSnapshot;
  final BallModel ball;

  ScoreActionSnapshot({
    required this.matchSnapshot,
    required this.ball,
  });
}

class ScoringService {
  final List<ScoreActionSnapshot> _undoStack = [];
  bool get canUndo => _undoStack.isNotEmpty;

  /// Record a ball delivery (Runs, Extras, Wickets)
  BallModel recordDelivery({
    required CricketMatch match,
    required int runs,
    int extras = 0,
    String? extraType,
    bool isWicket = false,
    String? wicketType,
    String? newBatterName,
  }) {
    // 1. Save snapshot for Undo
    _undoStack.add(
      ScoreActionSnapshot(
        matchSnapshot: _cloneMatch(match),
        ball: BallModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          over: match.currentInningsIndex == 1 ? match.team1.overs.floor() : match.team2.overs.floor(),
          ball: (CricketScoreUtils.oversToBalls(match.currentInningsIndex == 1 ? match.team1.overs : match.team2.overs) % 6) + 1,
          runs: runs,
          extras: extras,
          extraType: extraType,
          isWicket: isWicket,
          wicketType: wicketType,
          strikerId: match.striker?.name ?? '',
          strikerName: match.striker?.name ?? 'Striker',
          nonStrikerId: match.nonStriker?.name ?? '',
          nonStrikerName: match.nonStriker?.name ?? 'Non-Striker',
          bowlerId: match.bowler?.name ?? '',
          bowlerName: match.bowler?.name ?? 'Bowler',
          description: _generateDescription(match, runs, extraType, isWicket),
        ),
      ),
    );

    final battingTeam = match.currentInningsIndex == 1 ? match.team1 : match.team2;
    final scorecard = match.currentInningsIndex == 1 ? match.innings1 : match.innings2;

    final isLegalBall = extraType != 'wide' && extraType != 'noBall';
    final totalBallRuns = runs + extras;

    // 2. Update Batting Team total
    battingTeam.runs += totalBallRuns;
    if (scorecard != null) {
      scorecard.runs = battingTeam.runs;
    }

    // 3. Update Striker Stats
    if (match.striker != null) {
      if (extraType == null || extraType == 'noBall') {
        // Runs scored off the bat
        match.striker!.runs += runs;
        if (runs == 4) match.striker!.fours += 1;
        if (runs == 6) match.striker!.sixes += 1;
      }
      if (isLegalBall || extraType == 'noBall') {
        match.striker!.balls += 1;
      }
    }

    // 4. Update Bowler Stats
    if (match.bowler != null) {
      // Wides and No Balls count towards bowler's conceded runs
      if (extraType != 'bye' && extraType != 'legBye') {
        match.bowler!.runs += totalBallRuns;
      }
    }

    // 5. Update Legal Ball Overs Progression
    bool overCompleted = false;
    if (isLegalBall) {
      final curFull = battingTeam.overs.floor();
      final curBalls = ((battingTeam.overs - curFull) * 10).round() + 1;

      if (curBalls >= 6) {
        battingTeam.overs = (curFull + 1).toDouble();
        overCompleted = true;
      } else {
        battingTeam.overs = double.parse((curFull + (curBalls * 0.1)).toStringAsFixed(1));
      }

      if (scorecard != null) scorecard.overs = battingTeam.overs;

      // Bowler overs
      if (match.bowler != null) {
        final bFull = match.bowler!.overs.floor();
        final bBalls = ((match.bowler!.overs - bFull) * 10).round() + 1;
        if (bBalls >= 6) {
          match.bowler!.overs = (bFull + 1).toDouble();
        } else {
          match.bowler!.overs = double.parse((bFull + (bBalls * 0.1)).toStringAsFixed(1));
        }
      }
    }

    // 6. Handle Wicket
    if (isWicket) {
      battingTeam.wickets += 1;
      if (scorecard != null) {
        scorecard.wickets = battingTeam.wickets;
        if (match.bowler != null && wicketType != 'runOut') {
          match.bowler!.wickets += 1;
        }

        if (match.striker != null) {
          match.striker!.isOut = true;
          match.striker!.dismissal = wicketType == 'runOut' ? 'run out' : 'b ${match.bowler?.name}';

          scorecard.fallOfWickets.add(
            FallOfWicket(
              wicketNumber: battingTeam.wickets,
              score: battingTeam.runs,
              over: battingTeam.overs.toStringAsFixed(1),
              batter: match.striker!.name,
            ),
          );

          // Replace with next batter
          final nextName = newBatterName ?? 'Batter ${battingTeam.wickets + 2}';
          final nextBatter = BatterScore(
            name: nextName,
            runs: 0,
            balls: 0,
            fours: 0,
            sixes: 0,
            isStriker: true,
          );
          scorecard.batters.add(nextBatter);
          match.striker = nextBatter;
        }
      }
    }

    // 7. Update Recent Balls Pill
    final outcomeTag = CricketScoreUtils.formatOutcome(runs, extraType, isWicket);
    match.recentBalls.insert(0, outcomeTag);
    if (match.recentBalls.length > 8) {
      match.recentBalls.removeLast();
    }

    // 8. Commentary Entry
    final lastBallModel = _undoStack.last.ball;
    match.commentary.insert(
      0,
      CommentaryItem(
        id: lastBallModel.id,
        over: battingTeam.overs.toStringAsFixed(1),
        outcome: outcomeTag,
        title: _generateTitle(runs, extraType, isWicket, match),
        description: lastBallModel.description,
        bowler: match.bowler?.name ?? '',
        batsman: match.striker?.name ?? '',
        timestamp: DateTime.now(),
        isBoundary: runs == 4,
        isSix: runs == 6,
        isWicket: isWicket,
      ),
    );

    // 9. Strike Rotation on Odd Runs
    if (!isWicket && (runs == 1 || runs == 3)) {
      _swapStrikers(match);
    }

    // 10. Over Completed Logic
    if (overCompleted) {
      _swapStrikers(match);
    }

    // 11. Recalculate target equation
    _updateEquation(match);

    return lastBallModel;
  }

  /// Undo the last delivery action
  CricketMatch? undoLastDelivery(CricketMatch currentMatch) {
    if (_undoStack.isEmpty) return null;
    final lastSnapshot = _undoStack.removeLast();
    _restoreMatch(currentMatch, lastSnapshot.matchSnapshot);
    if (currentMatch.commentary.isNotEmpty) {
      currentMatch.commentary.removeAt(0);
    }
    return currentMatch;
  }

  /// Swap striker and non-striker
  void swapStrikers(CricketMatch match) {
    _swapStrikers(match);
  }

  void _swapStrikers(CricketMatch match) {
    if (match.striker == null || match.nonStriker == null) return;
    final temp = match.striker!;
    match.striker = match.nonStriker;
    match.nonStriker = temp;
    match.striker!.isStriker = true;
    match.nonStriker!.isStriker = false;
  }

  void _updateEquation(CricketMatch match) {
    final batting = match.currentInningsIndex == 1 ? match.team1 : match.team2;
    final bowling = match.currentInningsIndex == 1 ? match.team2 : match.team1;

    if (match.target != null) {
      match.requiredRuns = (match.target! - batting.runs).clamp(0, 999);
      final ballsBowled = CricketScoreUtils.oversToBalls(batting.overs);
      match.ballsRemaining = (120 - ballsBowled).clamp(0, 120);

      if (batting.runs >= match.target!) {
        match.status = MatchStatus.completed;
        match.resultSummary = '${batting.name} won by ${10 - batting.wickets} wickets!';
        match.currentEquation = 'Match Finished • ${batting.name} won!';
      } else if (match.ballsRemaining! <= 0 || batting.wickets >= 10) {
        match.status = MatchStatus.completed;
        final diff = (match.target! - 1) - batting.runs;
        match.resultSummary = diff > 0 ? '${bowling.name} won by $diff runs!' : 'Match Tied!';
        match.currentEquation = 'Match Finished • ${match.resultSummary}';
      } else {
        match.currentEquation = 'Need ${match.requiredRuns} runs in ${match.ballsRemaining} balls';
      }
    } else {
      match.currentEquation = '1st Innings • CRR: ${match.currentRunRate.toStringAsFixed(2)}';
    }
  }

  String _generateTitle(int runs, String? extraType, bool isWicket, CricketMatch match) {
    if (isWicket) return 'WICKET! Breakthrough for ${match.bowler?.name ?? "Bowler"}!';
    if (runs == 6) return 'SIX! Maximum over the boundary!';
    if (runs == 4) return 'FOUR! Pierces the outfield!';
    if (extraType == 'wide') return 'Wide delivery called';
    if (extraType == 'noBall') return 'No Ball! Free hit coming up';
    if (runs == 0) return 'Dot ball';
    return '$runs run${runs > 1 ? "s" : ""} taken';
  }

  String _generateDescription(CricketMatch match, int runs, String? extraType, bool isWicket) {
    final bName = match.bowler?.name ?? 'Bowler';
    final sName = match.striker?.name ?? 'Striker';
    if (isWicket) return '$bName strikes! $sName departs after a hard-fought innings.';
    if (runs == 6) return '$bName to $sName, SIX! Full on middle, launched straight down the ground!';
    if (runs == 4) return '$bName to $sName, FOUR! Driven through extra cover with pure timing.';
    if (extraType == 'wide') return '$bName sprays down leg side, umpire signals wide.';
    if (extraType == 'noBall') return '$bName oversteps the crease. No Ball signaled.';
    if (runs == 0) return '$bName to $sName, no run. Defended cautiously into the covers.';
    return '$bName to $sName, $runs run${runs > 1 ? "s" : ""}, punched into the gap.';
  }

  CricketMatch _cloneMatch(CricketMatch m) {
    return CricketMatch(
      id: m.id,
      title: m.title,
      series: m.series,
      stage: m.stage,
      matchType: m.matchType,
      venue: m.venue,
      dateStr: m.dateStr,
      pitchReport: m.pitchReport,
      weather: m.weather,
      toss: m.toss,
      status: m.status,
      resultSummary: m.resultSummary,
      currentEquation: m.currentEquation,
      currentInningsIndex: m.currentInningsIndex,
      team1: MatchTeam(
        name: m.team1.name,
        shortCode: m.team1.shortCode,
        flagEmoji: m.team1.flagEmoji,
        primaryColor: m.team1.primaryColor,
        secondaryColor: m.team1.secondaryColor,
        runs: m.team1.runs,
        wickets: m.team1.wickets,
        overs: m.team1.overs,
        isBatting: m.team1.isBatting,
      ),
      team2: MatchTeam(
        name: m.team2.name,
        shortCode: m.team2.shortCode,
        flagEmoji: m.team2.flagEmoji,
        primaryColor: m.team2.primaryColor,
        secondaryColor: m.team2.secondaryColor,
        runs: m.team2.runs,
        wickets: m.team2.wickets,
        overs: m.team2.overs,
        isBatting: m.team2.isBatting,
      ),
      target: m.target,
      requiredRuns: m.requiredRuns,
      ballsRemaining: m.ballsRemaining,
      recentBalls: List.from(m.recentBalls),
      striker: m.striker?.copyWith(),
      nonStriker: m.nonStriker?.copyWith(),
      bowler: m.bowler?.copyWith(),
      innings1: m.innings1,
      innings2: m.innings2,
      commentary: List.from(m.commentary),
      team1Squad: m.team1Squad,
      team2Squad: m.team2Squad,
      runProgressionTeam1: List.from(m.runProgressionTeam1),
      runProgressionTeam2: List.from(m.runProgressionTeam2),
    );
  }

  void _restoreMatch(CricketMatch target, CricketMatch source) {
    target.team1.runs = source.team1.runs;
    target.team1.wickets = source.team1.wickets;
    target.team1.overs = source.team1.overs;
    target.team2.runs = source.team2.runs;
    target.team2.wickets = source.team2.wickets;
    target.team2.overs = source.team2.overs;
    target.currentEquation = source.currentEquation;
    target.resultSummary = source.resultSummary;
    target.status = source.status;
    target.recentBalls = List.from(source.recentBalls);
    target.striker = source.striker;
    target.nonStriker = source.nonStriker;
    target.bowler = source.bowler;
  }
}
