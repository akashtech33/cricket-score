class PlayerModel {
  final String id;
  final String name;
  final String teamId;
  final String role; // 'Batter', 'Bowler', 'All-rounder', 'Wicketkeeper'
  final bool isCaptain;
  final bool isWicketkeeper;

  // Batting stats
  int runs;
  int balls;
  int fours;
  int sixes;
  bool isOut;
  String dismissal;

  // Bowling stats
  double oversBowled;
  int maidens;
  int runsConceded;
  int wicketsTaken;

  PlayerModel({
    required this.id,
    required this.name,
    required this.teamId,
    this.role = 'Batter',
    this.isCaptain = false,
    this.isWicketkeeper = false,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.isOut = false,
    this.dismissal = 'not out',
    this.oversBowled = 0.0,
    this.maidens = 0,
    this.runsConceded = 0,
    this.wicketsTaken = 0,
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  double get bowlingEconomy {
    final full = oversBowled.floor();
    final balls = ((oversBowled - full) * 10).round();
    final totalBalls = (full * 6) + balls;
    if (totalBalls == 0) return 0.0;
    return (runsConceded / totalBalls) * 6.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
      'role': role,
      'isCaptain': isCaptain,
      'isWicketkeeper': isWicketkeeper,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'isOut': isOut,
      'dismissal': dismissal,
      'oversBowled': oversBowled,
      'maidens': maidens,
      'runsConceded': runsConceded,
      'wicketsTaken': wicketsTaken,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map, [String? fallbackId]) {
    return PlayerModel(
      id: map['id'] ?? fallbackId ?? '',
      name: map['name'] ?? '',
      teamId: map['teamId'] ?? '',
      role: map['role'] ?? 'Batter',
      isCaptain: map['isCaptain'] ?? false,
      isWicketkeeper: map['isWicketkeeper'] ?? false,
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      balls: (map['balls'] as num?)?.toInt() ?? 0,
      fours: (map['fours'] as num?)?.toInt() ?? 0,
      sixes: (map['sixes'] as num?)?.toInt() ?? 0,
      isOut: map['isOut'] ?? false,
      dismissal: map['dismissal'] ?? 'not out',
      oversBowled: (map['oversBowled'] as num?)?.toDouble() ?? 0.0,
      maidens: (map['maidens'] as num?)?.toInt() ?? 0,
      runsConceded: (map['runsConceded'] as num?)?.toInt() ?? 0,
      wicketsTaken: (map['wicketsTaken'] as num?)?.toInt() ?? 0,
    );
  }

  PlayerModel copyWith({
    String? id,
    String? name,
    String? teamId,
    String? role,
    bool? isCaptain,
    bool? isWicketkeeper,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    bool? isOut,
    String? dismissal,
    double? oversBowled,
    int? maidens,
    int? runsConceded,
    int? wicketsTaken,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      isCaptain: isCaptain ?? this.isCaptain,
      isWicketkeeper: isWicketkeeper ?? this.isWicketkeeper,
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      isOut: isOut ?? this.isOut,
      dismissal: dismissal ?? this.dismissal,
      oversBowled: oversBowled ?? this.oversBowled,
      maidens: maidens ?? this.maidens,
      runsConceded: runsConceded ?? this.runsConceded,
      wicketsTaken: wicketsTaken ?? this.wicketsTaken,
    );
  }
}
