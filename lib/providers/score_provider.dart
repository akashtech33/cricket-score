import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/scorecard_model.dart';
import '../services/scoring_service.dart';
import '../services/firestore_service.dart';

class ScoreProvider extends ChangeNotifier {
  final ScoringService _scoringService = ScoringService();
  final FirestoreService _firestoreService;

  CricketMatch? _currentMatch;
  bool _isProcessing = false;

  ScoreProvider({required this._firestoreService});

  CricketMatch? get currentMatch => _currentMatch;
  bool get canUndo => _scoringService.canUndo;
  bool get isProcessing => _isProcessing;

  void setActiveMatch(CricketMatch match) {
    _currentMatch = match;
    notifyListeners();
  }

  /// Record runs off the bat (0, 1, 2, 3, 4, 6)
  Future<void> recordRuns(int runs) async {
    if (_currentMatch == null || _isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    final ball = _scoringService.recordDelivery(
      match: _currentMatch!,
      runs: runs,
    );

    await _firestoreService.recordBall(_currentMatch!.id, ball, _currentMatch!);
    _isProcessing = false;
    notifyListeners();
  }

  /// Record extra delivery (wide, no-ball, bye, leg-bye)
  Future<void> recordExtra(String extraType, [int additionalRuns = 0]) async {
    if (_currentMatch == null || _isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    int extras = 1;
    int runsOffBat = 0;

    if (extraType == 'wide' || extraType == 'noBall') {
      extras = 1 + additionalRuns;
    } else if (extraType == 'bye' || extraType == 'legBye') {
      extras = additionalRuns > 0 ? additionalRuns : 1;
    }

    final ball = _scoringService.recordDelivery(
      match: _currentMatch!,
      runs: runsOffBat,
      extras: extras,
      extraType: extraType,
    );

    await _firestoreService.recordBall(_currentMatch!.id, ball, _currentMatch!);
    _isProcessing = false;
    notifyListeners();
  }

  /// Record a wicket
  Future<void> recordWicket({String wicketType = 'bowled', String? nextBatterName}) async {
    if (_currentMatch == null || _isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    final ball = _scoringService.recordDelivery(
      match: _currentMatch!,
      runs: 0,
      isWicket: true,
      wicketType: wicketType,
      newBatterName: nextBatterName,
    );

    await _firestoreService.recordBall(_currentMatch!.id, ball, _currentMatch!);
    _isProcessing = false;
    notifyListeners();
  }

  /// Undo the last delivery
  Future<void> undo() async {
    if (_currentMatch == null || !canUndo || _isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    final reverted = _scoringService.undoLastDelivery(_currentMatch!);
    if (reverted != null) {
      _currentMatch = reverted;
      final lastBallId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestoreService.undoLastBall(_currentMatch!.id, lastBallId, _currentMatch!);
    }

    _isProcessing = false;
    notifyListeners();
  }

  /// Swap striker and non-striker manually
  void swapStrikers() {
    if (_currentMatch == null) return;
    _scoringService.swapStrikers(_currentMatch!);
    notifyListeners();
  }

  /// Change active bowler
  void changeBowler(String newBowlerName) {
    if (_currentMatch == null) return;
    final scorecard = _currentMatch!.currentInningsIndex == 1 ? _currentMatch!.innings1 : _currentMatch!.innings2;

    if (scorecard != null) {
      var bowler = scorecard.bowlers.firstWhere(
        (b) => b.name == newBowlerName,
        orElse: () {
          final newB = BowlerScore(name: newBowlerName, overs: 0, maidens: 0, runs: 0, wickets: 0);
          scorecard.bowlers.add(newB);
          return newB;
        },
      );
      _currentMatch!.bowler = bowler;
    }
    notifyListeners();
  }

  /// Change striker
  void changeStriker(String batterName) {
    if (_currentMatch == null) return;
    final scorecard = _currentMatch!.currentInningsIndex == 1 ? _currentMatch!.innings1 : _currentMatch!.innings2;

    if (scorecard != null) {
      var batter = scorecard.batters.firstWhere(
        (b) => b.name == batterName,
        orElse: () {
          final newBat = BatterScore(name: batterName, runs: 0, balls: 0, fours: 0, sixes: 0, isStriker: true);
          scorecard.batters.add(newBat);
          return newBat;
        },
      );
      _currentMatch!.striker = batter;
    }
    notifyListeners();
  }

  /// Change non-striker
  void changeNonStriker(String batterName) {
    if (_currentMatch == null) return;
    final scorecard = _currentMatch!.currentInningsIndex == 1 ? _currentMatch!.innings1 : _currentMatch!.innings2;

    if (scorecard != null) {
      var batter = scorecard.batters.firstWhere(
        (b) => b.name == batterName,
        orElse: () {
          final newBat = BatterScore(name: batterName, runs: 0, balls: 0, fours: 0, sixes: 0, isNonStriker: true);
          scorecard.batters.add(newBat);
          return newBat;
        },
      );
      _currentMatch!.nonStriker = batter;
    }
    notifyListeners();
  }

  /// Switch Innings (End 1st Innings and begin 2nd Innings)
  Future<void> endInnings() async {
    if (_currentMatch == null) return;
    _currentMatch!.currentInningsIndex = 2;
    _currentMatch!.target = _currentMatch!.team1.runs + 1;
    _currentMatch!.team1.isBatting = false;
    _currentMatch!.team2.isBatting = true;
    _currentMatch!.currentEquation = 'Target ${_currentMatch!.target} • Chasing ${_currentMatch!.team2.name}';

    // Init team 2 scorecard if needed
    if (_currentMatch!.innings2 == null) {
      _currentMatch!.innings2 = InningsScorecard(
        teamShort: _currentMatch!.team2.shortCode,
        teamName: _currentMatch!.team2.name,
        runs: 0,
        wickets: 0,
        overs: 0,
        extras: InningsExtras(),
        batters: [
          BatterScore(name: 'Opener 1', runs: 0, balls: 0, fours: 0, sixes: 0, isStriker: true),
          BatterScore(name: 'Opener 2', runs: 0, balls: 0, fours: 0, sixes: 0, isNonStriker: true),
        ],
        bowlers: [
          BowlerScore(name: 'Opening Bowler', overs: 0, maidens: 0, runs: 0, wickets: 0),
        ],
        fallOfWickets: [],
      );
      _currentMatch!.striker = _currentMatch!.innings2!.batters[0];
      _currentMatch!.nonStriker = _currentMatch!.innings2!.batters[1];
      _currentMatch!.bowler = _currentMatch!.innings2!.bowlers[0];
    }

    notifyListeners();
  }

  /// End Match
  Future<void> endMatch(String result) async {
    if (_currentMatch == null) return;
    _currentMatch!.status = MatchStatus.completed;
    _currentMatch!.resultSummary = result;
    _currentMatch!.currentEquation = 'Match Finished • $result';
    notifyListeners();
  }
}
