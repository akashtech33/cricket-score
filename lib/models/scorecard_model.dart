class BatterScore {
  final String name;
  String dismissal;
  String bowler;
  int runs;
  int balls;
  int fours;
  int sixes;
  bool isOut;
  bool isStriker;
  bool isNonStriker;

  BatterScore({
    required this.name,
    this.dismissal = 'not out',
    this.bowler = '',
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    this.isOut = false,
    this.isStriker = false,
    this.isNonStriker = false,
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  BatterScore copyWith({
    String? name,
    String? dismissal,
    String? bowler,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    bool? isOut,
    bool? isStriker,
    bool? isNonStriker,
  }) {
    return BatterScore(
      name: name ?? this.name,
      dismissal: dismissal ?? this.dismissal,
      bowler: bowler ?? this.bowler,
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      isOut: isOut ?? this.isOut,
      isStriker: isStriker ?? this.isStriker,
      isNonStriker: isNonStriker ?? this.isNonStriker,
    );
  }
}

class BowlerScore {
  final String name;
  double overs;
  int maidens;
  int runs;
  int wickets;
  int dots;

  BowlerScore({
    required this.name,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
    this.dots = 0,
  });

  double get economy {
    final fullOvers = overs.floor();
    final balls = ((overs - fullOvers) * 10).round();
    final totalBalls = (fullOvers * 6) + balls;
    if (totalBalls == 0) return 0.0;
    return (runs / totalBalls) * 6.0;
  }

  BowlerScore copyWith({
    String? name,
    double? overs,
    int? maidens,
    int? runs,
    int? wickets,
    int? dots,
  }) {
    return BowlerScore(
      name: name ?? this.name,
      overs: overs ?? this.overs,
      maidens: maidens ?? this.maidens,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      dots: dots ?? this.dots,
    );
  }
}

class FallOfWicket {
  final int wicketNumber;
  final int score;
  final String over;
  final String batter;

  FallOfWicket({
    required this.wicketNumber,
    required this.score,
    required this.over,
    required this.batter,
  });
}

class InningsExtras {
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;

  InningsExtras({
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
  });

  int get total => wides + noBalls + byes + legByes;
}

class InningsScorecard {
  final String teamShort;
  final String teamName;
  int runs;
  int wickets;
  double overs;
  InningsExtras extras;
  List<BatterScore> batters;
  List<BowlerScore> bowlers;
  List<FallOfWicket> fallOfWickets;
  List<String> didNotBat;

  InningsScorecard({
    required this.teamShort,
    required this.teamName,
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.extras,
    required this.batters,
    required this.bowlers,
    required this.fallOfWickets,
    this.didNotBat = const [],
  });
}
