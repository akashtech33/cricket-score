class InningsModel {
  final String id;
  final String matchId;
  final int inningsNumber; // 1 or 2
  final String battingTeamId;
  final String bowlingTeamId;
  int runs;
  int wickets;
  double overs;
  int balls;
  int? target;
  bool isCompleted;

  InningsModel({
    required this.id,
    required this.matchId,
    required this.inningsNumber,
    required this.battingTeamId,
    required this.bowlingTeamId,
    this.runs = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.balls = 0,
    this.target,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchId': matchId,
      'inningsNumber': inningsNumber,
      'battingTeamId': battingTeamId,
      'bowlingTeamId': bowlingTeamId,
      'runs': runs,
      'wickets': wickets,
      'overs': overs,
      'balls': balls,
      'target': target,
      'isCompleted': isCompleted,
    };
  }

  factory InningsModel.fromMap(Map<String, dynamic> map, [String? fallbackId]) {
    return InningsModel(
      id: map['id'] ?? fallbackId ?? '',
      matchId: map['matchId'] ?? '',
      inningsNumber: (map['inningsNumber'] as num?)?.toInt() ?? 1,
      battingTeamId: map['battingTeamId'] ?? '',
      bowlingTeamId: map['bowlingTeamId'] ?? '',
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      wickets: (map['wickets'] as num?)?.toInt() ?? 0,
      overs: (map['overs'] as num?)?.toDouble() ?? 0.0,
      balls: (map['balls'] as num?)?.toInt() ?? 0,
      target: (map['target'] as num?)?.toInt(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
