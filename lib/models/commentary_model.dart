class CommentaryItem {
  final String id;
  final String over;        // e.g. "18.4"
  final String outcome;     // "0", "1", "2", "3", "4", "6", "W", "Wd", "Nb"
  final String title;       // e.g. "FOUR! Sublime cover drive!"
  final String description; // Detailed description of the delivery and shot
  final String bowler;
  final String batsman;
  final DateTime timestamp;
  final bool isBoundary;
  final bool isSix;
  final bool isWicket;
  final bool isMilestone;
  final bool isOverSummary;
  final String? overSummaryRuns;

  CommentaryItem({
    required this.id,
    required this.over,
    required this.outcome,
    required this.title,
    required this.description,
    required this.bowler,
    required this.batsman,
    required this.timestamp,
    this.isBoundary = false,
    this.isSix = false,
    this.isWicket = false,
    this.isMilestone = false,
    this.isOverSummary = false,
    this.overSummaryRuns,
  });
}
