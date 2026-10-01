import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/scorecard_model.dart';
import '../models/ball_model.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // In-memory fallback stream controller for offline/local evaluation
  final _matchesController = StreamController<List<CricketMatch>>.broadcast();
  final Map<String, StreamController<CricketMatch>> _matchControllers = {};
  final Map<String, List<BallModel>> _ballsHistory = {};

  List<CricketMatch> _localMatches = [];

  FirestoreService() {
    _initLocalSeed();
  }

  void _initLocalSeed() {
    // Initial local matches
    _matchesController.add(_localMatches);
  }

  void setLocalMatches(List<CricketMatch> matches) {
    _localMatches = matches;
    _matchesController.add(_localMatches);
  }

  /// Real-time stream of all matches
  Stream<List<CricketMatch>> getMatchesStream() async* {
    yield _localMatches;
    final firestore = _firestore;
    if (firestore != null) {
      try {
        yield* firestore
            .collection('matches')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              if (snapshot.docs.isEmpty) return _localMatches;
              return snapshot.docs.map((doc) {
                return _matchFromFirestore(doc.data(), doc.id);
              }).toList();
            })
            .handleError((e) {
              debugPrint('Firestore matches stream notice: $e');
              return _localMatches;
            });
        return;
      } catch (_) {}
    }
    yield* _matchesController.stream;
  }

  /// Real-time stream of a specific live match
  Stream<CricketMatch?> getMatchStream(String matchId) async* {
    yield _getLocalMatchById(matchId);
    final firestore = _firestore;
    if (firestore != null) {
      try {
        yield* firestore.collection('matches').doc(matchId).snapshots().map((doc) {
          if (!doc.exists || doc.data() == null) {
            return _getLocalMatchById(matchId);
          }
          return _matchFromFirestore(doc.data()!, doc.id);
        }).handleError((e) {
          debugPrint('Firestore match stream notice: $e');
          return _getLocalMatchById(matchId);
        });
        return;
      } catch (_) {}
    }
    if (!_matchControllers.containsKey(matchId)) {
      _matchControllers[matchId] = StreamController<CricketMatch>.broadcast();
    }
    yield* _matchControllers[matchId]!.stream;
  }

  /// Real-time stream of ball-by-ball actions for a match
  Stream<List<BallModel>> getBallsStream(String matchId) async* {
    yield _ballsHistory[matchId] ?? [];
    final firestore = _firestore;
    if (firestore != null) {
      try {
        yield* firestore
            .collection('matches')
            .doc(matchId)
            .collection('balls')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) {
              if (snapshot.docs.isEmpty) return _ballsHistory[matchId] ?? [];
              return snapshot.docs.map((doc) => BallModel.fromMap(doc.data(), doc.id)).toList();
            })
            .handleError((e) {
              return _ballsHistory[matchId] ?? [];
            });
        return;
      } catch (_) {}
    }
  }

  /// Create a new match in Firestore
  Future<void> createMatch(CricketMatch match) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final docRef = firestore.collection('matches').doc(match.id);
        await docRef.set({
          'id': match.id,
          'title': match.title,
          'series': match.series,
          'stage': match.stage,
          'venue': match.venue,
          'dateStr': match.dateStr,
          'status': match.status.name,
          'currentEquation': match.currentEquation,
          'resultSummary': match.resultSummary,
          'target': match.target,
          'currentInningsIndex': match.currentInningsIndex,
          'toss': match.toss,
          'team1': {
            'name': match.team1.name,
            'shortCode': match.team1.shortCode,
            'flagEmoji': match.team1.flagEmoji,
            'runs': match.team1.runs,
            'wickets': match.team1.wickets,
            'overs': match.team1.overs,
            'isBatting': match.team1.isBatting,
          },
          'team2': {
            'name': match.team2.name,
            'shortCode': match.team2.shortCode,
            'flagEmoji': match.team2.flagEmoji,
            'runs': match.team2.runs,
            'wickets': match.team2.wickets,
            'overs': match.team2.overs,
            'isBatting': match.team2.isBatting,
          },
          'recentBalls': match.recentBalls,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore createMatch local sync notice: $e');
      }
    }

    // Local state sync
    _localMatches.insert(0, match);
    _matchesController.add(List.from(_localMatches));
    _notifyLocalMatch(match);
  }

  /// Save a delivery record to matches/{matchId}/balls/{ballId}
  Future<void> recordBall(String matchId, BallModel ball, CricketMatch updatedMatch) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final matchRef = firestore.collection('matches').doc(matchId);

        // 1. Add ball record
        await matchRef.collection('balls').doc(ball.id).set(ball.toMap());

        // 2. Update match root summary
        await matchRef.update({
          'currentEquation': updatedMatch.currentEquation,
          'resultSummary': updatedMatch.resultSummary,
          'status': updatedMatch.status.name,
          'currentInningsIndex': updatedMatch.currentInningsIndex,
          'recentBalls': updatedMatch.recentBalls,
          'target': updatedMatch.target,
          'team1': {
            'name': updatedMatch.team1.name,
            'shortCode': updatedMatch.team1.shortCode,
            'flagEmoji': updatedMatch.team1.flagEmoji,
            'runs': updatedMatch.team1.runs,
            'wickets': updatedMatch.team1.wickets,
            'overs': updatedMatch.team1.overs,
            'isBatting': updatedMatch.team1.isBatting,
          },
          'team2': {
            'name': updatedMatch.team2.name,
            'shortCode': updatedMatch.team2.shortCode,
            'flagEmoji': updatedMatch.team2.flagEmoji,
            'runs': updatedMatch.team2.runs,
            'wickets': updatedMatch.team2.wickets,
            'overs': updatedMatch.team2.overs,
            'isBatting': updatedMatch.team2.isBatting,
          },
        });
      } catch (e) {
        debugPrint('Firestore recordBall local sync notice: $e');
      }
    }

    // Local state sync
    if (!_ballsHistory.containsKey(matchId)) {
      _ballsHistory[matchId] = [];
    }
    _ballsHistory[matchId]!.insert(0, ball);
    _notifyLocalMatch(updatedMatch);
  }

  /// Undo last ball action
  Future<void> undoLastBall(String matchId, String ballId, CricketMatch revertedMatch) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final matchRef = firestore.collection('matches').doc(matchId);
        await matchRef.collection('balls').doc(ballId).delete();
        await matchRef.update({
          'currentEquation': revertedMatch.currentEquation,
          'recentBalls': revertedMatch.recentBalls,
          'team1.runs': revertedMatch.team1.runs,
          'team1.wickets': revertedMatch.team1.wickets,
          'team1.overs': revertedMatch.team1.overs,
          'team2.runs': revertedMatch.team2.runs,
          'team2.wickets': revertedMatch.team2.wickets,
          'team2.overs': revertedMatch.team2.overs,
        });
      } catch (e) {
        debugPrint('Firestore undoLastBall notice: $e');
      }
    }

    if (_ballsHistory.containsKey(matchId)) {
      _ballsHistory[matchId]!.removeWhere((b) => b.id == ballId);
    }
    _notifyLocalMatch(revertedMatch);
  }

  void _notifyLocalMatch(CricketMatch match) {
    final idx = _localMatches.indexWhere((m) => m.id == match.id);
    if (idx != -1) {
      _localMatches[idx] = match;
    } else {
      _localMatches.add(match);
    }
    _matchesController.add(List.from(_localMatches));

    if (_matchControllers.containsKey(match.id)) {
      _matchControllers[match.id]!.add(match);
    }
  }

  CricketMatch? _getLocalMatchById(String id) {
    try {
      return _localMatches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  CricketMatch _matchFromFirestore(Map<String, dynamic> data, String id) {
    final local = _getLocalMatchById(id);
    if (local != null) {
      // Merge remote stats into existing local full model
      final t1Map = data['team1'] as Map<String, dynamic>?;
      final t2Map = data['team2'] as Map<String, dynamic>?;

      if (t1Map != null) {
        local.team1.runs = (t1Map['runs'] as num?)?.toInt() ?? local.team1.runs;
        local.team1.wickets = (t1Map['wickets'] as num?)?.toInt() ?? local.team1.wickets;
        local.team1.overs = (t1Map['overs'] as num?)?.toDouble() ?? local.team1.overs;
        local.team1.isBatting = t1Map['isBatting'] ?? local.team1.isBatting;
      }
      if (t2Map != null) {
        local.team2.runs = (t2Map['runs'] as num?)?.toInt() ?? local.team2.runs;
        local.team2.wickets = (t2Map['wickets'] as num?)?.toInt() ?? local.team2.wickets;
        local.team2.overs = (t2Map['overs'] as num?)?.toDouble() ?? local.team2.overs;
        local.team2.isBatting = t2Map['isBatting'] ?? local.team2.isBatting;
      }

      local.currentEquation = data['currentEquation'] ?? local.currentEquation;
      local.resultSummary = data['resultSummary'] ?? local.resultSummary;
      if (data['recentBalls'] != null) {
        local.recentBalls = List<String>.from(data['recentBalls']);
      }
      return local;
    }

    // Default basic fallback
    return CricketMatch(
      id: id,
      title: data['title'] ?? 'Live Match',
      series: data['series'] ?? 'Cricket Series',
      stage: data['stage'] ?? 'League',
      matchType: MatchType.t20,
      venue: data['venue'] ?? 'Stadium',
      dateStr: data['dateStr'] ?? 'Today',
      pitchReport: 'Even bounce and carry',
      weather: '25°C • Clear',
      toss: data['toss'] ?? 'Toss done',
      status: MatchStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => MatchStatus.live,
      ),
      resultSummary: data['resultSummary'] ?? '',
      currentEquation: data['currentEquation'] ?? '',
      team1: MatchTeam(
        name: data['team1']?['name'] ?? 'Team A',
        shortCode: data['team1']?['shortCode'] ?? 'TMA',
        flagEmoji: data['team1']?['flagEmoji'] ?? '🏏',
        primaryColor: const Color(0xFF1E40AF),
        secondaryColor: const Color(0xFF00E5FF),
        runs: (data['team1']?['runs'] as num?)?.toInt() ?? 0,
        wickets: (data['team1']?['wickets'] as num?)?.toInt() ?? 0,
        overs: (data['team1']?['overs'] as num?)?.toDouble() ?? 0.0,
      ),
      team2: MatchTeam(
        name: data['team2']?['name'] ?? 'Team B',
        shortCode: data['team2']?['shortCode'] ?? 'TMB',
        flagEmoji: data['team2']?['flagEmoji'] ?? '🏏',
        primaryColor: const Color(0xFFEAB308),
        secondaryColor: const Color(0xFFFFB703),
        runs: (data['team2']?['runs'] as num?)?.toInt() ?? 0,
        wickets: (data['team2']?['wickets'] as num?)?.toInt() ?? 0,
        overs: (data['team2']?['overs'] as num?)?.toDouble() ?? 0.0,
      ),
      recentBalls: List<String>.from(data['recentBalls'] ?? []),
      innings1: InningsScorecard(
        teamShort: 'T1',
        teamName: 'Team 1',
        runs: 0,
        wickets: 0,
        overs: 0,
        extras: InningsExtras(),
        batters: [],
        bowlers: [],
        fallOfWickets: [],
      ),
      commentary: [],
      team1Squad: [],
      team2Squad: [],
      runProgressionTeam1: [],
      runProgressionTeam2: [],
    );
  }
}
