class CricketScoreUtils {
  /// Converts an overs double (e.g. 18.3) into total legal balls count (18*6 + 3 = 111)
  static int oversToBalls(double overs) {
    final fullOvers = overs.floor();
    final ballsInOver = ((overs - fullOvers) * 10).round();
    return (fullOvers * 6) + ballsInOver;
  }

  /// Converts a legal ball count (e.g. 111) into overs double (18.3)
  static double ballsToOvers(int totalBalls) {
    final fullOvers = totalBalls ~/ 6;
    final remainingBalls = totalBalls % 6;
    return double.parse('$fullOvers.$remainingBalls');
  }

  /// Calculates Current Run Rate (CRR)
  static double calculateCRR(int runs, double overs) {
    final totalBalls = oversToBalls(overs);
    if (totalBalls <= 0) return 0.0;
    return (runs / totalBalls) * 6.0;
  }

  /// Calculates Required Run Rate (RRR)
  static double calculateRRR(int? target, int currentRuns, int totalMatchOvers, double oversBowled) {
    if (target == null) return 0.0;
    final runsNeeded = target - currentRuns;
    final totalMatchBalls = totalMatchOvers * 6;
    final ballsBowled = oversToBalls(oversBowled);
    final ballsRemaining = totalMatchBalls - ballsBowled;

    if (runsNeeded <= 0) return 0.0;
    if (ballsRemaining <= 0) return 99.9;
    return (runsNeeded / ballsRemaining) * 6.0;
  }

  /// Checks if delivery counts towards legal balls in the over
  static bool isLegalDelivery(String? extraType) {
    return extraType != 'wide' && extraType != 'noBall';
  }

  /// Formats delivery outcome for display
  static String formatOutcome(int runs, String? extraType, bool isWicket) {
    if (isWicket) return 'W';
    if (extraType == 'wide') return 'WD';
    if (extraType == 'noBall') return 'NB';
    if (extraType == 'bye') return 'B$runs';
    if (extraType == 'legBye') return 'LB$runs';
    return runs.toString();
  }
}
