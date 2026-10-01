import 'package:flutter/material.dart';
import 'scorecard_model.dart';
import 'commentary_model.dart';

enum MatchStatus {
  live,
  upcoming,
  completed,
}

enum MatchType {
  t20,
  odi,
  test,
}

class MatchTeam {
  final String name;
  final String shortCode;
  final String flagEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  int runs;
  int wickets;
  double overs;
  bool isBatting;
  String? inningsString;

  MatchTeam({
    required this.name,
    required this.shortCode,
    required this.flagEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    this.runs = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.isBatting = false,
    this.inningsString,
  });

  String get scoreDisplay => '$runs/$wickets';
  String get oversDisplay => '(${overs.toStringAsFixed(1)} ov)';
}

class PlayerSquadInfo {
  final String name;
  final String role; // 'Batter', 'Wicketkeeper', 'All-rounder', 'Bowler'
  final bool isCaptain;
  final bool isKeeper;

  PlayerSquadInfo({
    required this.name,
    required this.role,
    this.isCaptain = false,
    this.isKeeper = false,
  });
}

class CricketMatch {
  final String id;
  final String title;
  final String series;
  final String stage;
  final MatchType matchType;
  final String venue;
  final String dateStr;
  final String pitchReport;
  final String weather;
  final String toss;
  MatchStatus status;
  String resultSummary;
  String currentEquation;
  int currentInningsIndex; // 1 or 2

  MatchTeam team1;
  MatchTeam team2;

  int? target;
  int? requiredRuns;
  int? ballsRemaining;

  List<String> recentBalls;
  BatterScore? striker;
  BatterScore? nonStriker;
  BowlerScore? bowler;

  int partnershipRuns;
  int partnershipBalls;

  double winProbabilityTeam1;
  double winProbabilityTeam2;

  InningsScorecard innings1;
  InningsScorecard? innings2;

  List<CommentaryItem> commentary;
  List<PlayerSquadInfo> team1Squad;
  List<PlayerSquadInfo> team2Squad;

  List<double> runProgressionTeam1;
  List<double> runProgressionTeam2;

  CricketMatch({
    required this.id,
    required this.title,
    required this.series,
    required this.stage,
    required this.matchType,
    required this.venue,
    required this.dateStr,
    required this.pitchReport,
    required this.weather,
    required this.toss,
    required this.status,
    required this.resultSummary,
    required this.currentEquation,
    this.currentInningsIndex = 1,
    required this.team1,
    required this.team2,
    this.target,
    this.requiredRuns,
    this.ballsRemaining,
    required this.recentBalls,
    this.striker,
    this.nonStriker,
    this.bowler,
    this.partnershipRuns = 0,
    this.partnershipBalls = 0,
    this.winProbabilityTeam1 = 50.0,
    this.winProbabilityTeam2 = 50.0,
    required this.innings1,
    this.innings2,
    required this.commentary,
    required this.team1Squad,
    required this.team2Squad,
    required this.runProgressionTeam1,
    required this.runProgressionTeam2,
  });

  MatchTeam get battingTeam => currentInningsIndex == 1 ? team1 : team2;
  MatchTeam get bowlingTeam => currentInningsIndex == 1 ? team2 : team1;

  double get currentRunRate {
    final totalBalls = _oversToBalls(battingTeam.overs);
    if (totalBalls == 0) return 0.0;
    return (battingTeam.runs / totalBalls) * 6.0;
  }

  double get requiredRunRate {
    if (requiredRuns == null || ballsRemaining == null || ballsRemaining! <= 0) {
      return 0.0;
    }
    return (requiredRuns! / ballsRemaining!) * 6.0;
  }

  static int _oversToBalls(double overs) {
    final fullOvers = overs.floor();
    final balls = ((overs - fullOvers) * 10).round();
    return (fullOvers * 6) + balls;
  }
}
