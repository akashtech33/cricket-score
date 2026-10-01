class PointsTableEntry {
  final int rank;
  final String teamName;
  final String shortCode;
  final String flagEmoji;
  final int played;
  final int won;
  final int lost;
  final int tied;
  final int noResult;
  final double netRunRate;
  final int points;
  final List<String> formGuide; // e.g. ['W', 'W', 'L', 'W', 'W']
  final bool isQualified;

  PointsTableEntry({
    required this.rank,
    required this.teamName,
    required this.shortCode,
    required this.flagEmoji,
    required this.played,
    required this.won,
    required this.lost,
    this.tied = 0,
    this.noResult = 0,
    required this.netRunRate,
    required this.points,
    required this.formGuide,
    this.isQualified = false,
  });

  String get nrrDisplay => (netRunRate >= 0 ? '+' : '') + netRunRate.toStringAsFixed(3);
}

class TournamentGroup {
  final String groupName;
  final List<PointsTableEntry> standings;

  TournamentGroup({
    required this.groupName,
    required this.standings,
  });
}
