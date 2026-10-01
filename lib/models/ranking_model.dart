class PlayerRanking {
  final int rank;
  final String name;
  final String teamShort;
  final String flagEmoji;
  final int rating;
  final String pointsDiff; // e.g. "+2", "0", "-1"
  final String role; // 'Batting', 'Bowling', 'All-Rounder'
  final String format; // 'T20I', 'ODI', 'Test'

  PlayerRanking({
    required this.rank,
    required this.name,
    required this.teamShort,
    required this.flagEmoji,
    required this.rating,
    this.pointsDiff = '0',
    required this.role,
    required this.format,
  });
}
