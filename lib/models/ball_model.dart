class BallModel {
  final String id;
  final int over;        // 0-indexed over e.g. 0, 1, 2...
  final int ball;        // 1 to 6 (or ball in over)
  final int runs;        // runs scored by batter off the bat
  final int extras;      // extra runs (wides, no-balls, byes, leg-byes)
  final String? extraType; // 'wide', 'noBall', 'bye', 'legBye', null
  final bool isWicket;
  final String? wicketType; // 'bowled', 'caught', 'lbw', 'runOut', 'stumped'
  final String strikerId;
  final String strikerName;
  final String nonStrikerId;
  final String nonStrikerName;
  final String bowlerId;
  final String bowlerName;
  final String description;
  final DateTime timestamp;

  BallModel({
    required this.id,
    required this.over,
    required this.ball,
    required this.runs,
    this.extras = 0,
    this.extraType,
    this.isWicket = false,
    this.wicketType,
    required this.strikerId,
    required this.strikerName,
    required this.nonStrikerId,
    required this.nonStrikerName,
    required this.bowlerId,
    required this.bowlerName,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  int get totalRuns => runs + extras;
  bool get isLegal => extraType != 'wide' && extraType != 'noBall';
  String get ballDisplay => '$over.$ball';

  String get outcomeTag {
    if (isWicket) return 'W';
    if (extraType == 'wide') return 'WD';
    if (extraType == 'noBall') return 'NB';
    if (extraType == 'bye') return 'B';
    if (extraType == 'legBye') return 'LB';
    return runs.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'over': over,
      'ball': ball,
      'runs': runs,
      'extras': extras,
      'extraType': extraType,
      'isWicket': isWicket,
      'wicketType': wicketType,
      'strikerId': strikerId,
      'strikerName': strikerName,
      'nonStrikerId': nonStrikerId,
      'nonStrikerName': nonStrikerName,
      'bowlerId': bowlerId,
      'bowlerName': bowlerName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BallModel.fromMap(Map<String, dynamic> map, [String? fallbackId]) {
    return BallModel(
      id: map['id'] ?? fallbackId ?? '',
      over: (map['over'] as num?)?.toInt() ?? 0,
      ball: (map['ball'] as num?)?.toInt() ?? 1,
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      extras: (map['extras'] as num?)?.toInt() ?? 0,
      extraType: map['extraType'],
      isWicket: map['isWicket'] ?? false,
      wicketType: map['wicketType'],
      strikerId: map['strikerId'] ?? '',
      strikerName: map['strikerName'] ?? '',
      nonStrikerId: map['nonStrikerId'] ?? '',
      nonStrikerName: map['nonStrikerName'] ?? '',
      bowlerId: map['bowlerId'] ?? '',
      bowlerName: map['bowlerName'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
