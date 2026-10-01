import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_score/utils/cricket_score_utils.dart';
import 'package:cricket_score/services/cricket_data_service.dart';
import 'package:cricket_score/services/firestore_service.dart';
import 'package:cricket_score/providers/score_provider.dart';

void main() {
  group('CricketScoreUtils Tests', () {
    test('oversToBalls converts cricket overs to total legal balls', () {
      expect(CricketScoreUtils.oversToBalls(0.0), 0);
      expect(CricketScoreUtils.oversToBalls(0.1), 1);
      expect(CricketScoreUtils.oversToBalls(0.5), 5);
      expect(CricketScoreUtils.oversToBalls(1.0), 6);
      expect(CricketScoreUtils.oversToBalls(19.5), 119);
      expect(CricketScoreUtils.oversToBalls(20.0), 120);
    });

    test('ballsToOvers converts total balls to overs double', () {
      expect(CricketScoreUtils.ballsToOvers(0), 0.0);
      expect(CricketScoreUtils.ballsToOvers(1), 0.1);
      expect(CricketScoreUtils.ballsToOvers(5), 0.5);
      expect(CricketScoreUtils.ballsToOvers(6), 1.0);
      expect(CricketScoreUtils.ballsToOvers(119), 19.5);
      expect(CricketScoreUtils.ballsToOvers(120), 20.0);
    });

    test('calculateCRR computes Current Run Rate accurately', () {
      expect(CricketScoreUtils.calculateCRR(120, 20.0), 6.0);
      expect(CricketScoreUtils.calculateCRR(75, 10.0), 7.5);
      expect(CricketScoreUtils.calculateCRR(0, 0.0), 0.0);
      expect(CricketScoreUtils.calculateCRR(10, 1.2), 7.5);
    });

    test('calculateRRR computes Required Run Rate accurately', () {
      // 50 runs needed off 5 overs (oversBowled=15.0, totalMatchOvers=20)
      // totalMatchBalls=120, ballsBowled=90 -> 30 balls remaining -> 50 / 30 * 6 = 10.0
      expect(CricketScoreUtils.calculateRRR(150, 100, 20, 15.0), 10.0);
      expect(CricketScoreUtils.calculateRRR(100, 100, 20, 15.0), 0.0);
      expect(CricketScoreUtils.calculateRRR(null, 100, 20, 15.0), 0.0);
    });

    test('isLegalDelivery distinguishes legal balls from extras', () {
      expect(CricketScoreUtils.isLegalDelivery(null), isTrue);
      expect(CricketScoreUtils.isLegalDelivery('bye'), isTrue);
      expect(CricketScoreUtils.isLegalDelivery('legBye'), isTrue);
      expect(CricketScoreUtils.isLegalDelivery('wide'), isFalse);
      expect(CricketScoreUtils.isLegalDelivery('noBall'), isFalse);
    });

    test('formatOutcome formats delivery results for pills', () {
      expect(CricketScoreUtils.formatOutcome(0, null, false), '0');
      expect(CricketScoreUtils.formatOutcome(4, null, false), '4');
      expect(CricketScoreUtils.formatOutcome(6, null, false), '6');
      expect(CricketScoreUtils.formatOutcome(1, 'wide', false), 'WD');
      expect(CricketScoreUtils.formatOutcome(1, 'noBall', false), 'NB');
      expect(CricketScoreUtils.formatOutcome(0, null, true), 'W');
    });
  });

  group('Scoring Engine & Provider Integration Tests', () {
    late FirestoreService firestoreService;
    late CricketDataService dataService;
    late ScoreProvider scoreProvider;

    setUp(() {
      firestoreService = FirestoreService();
      dataService = CricketDataService();
      scoreProvider = ScoreProvider(firestoreService: firestoreService);
      // Select the first live demo match
      scoreProvider.setActiveMatch(dataService.matches.first);
    });

    test('Records dot ball and updates overs count', () async {
      final initialOvers = scoreProvider.currentMatch!.battingTeam.overs;
      final initialRuns = scoreProvider.currentMatch!.battingTeam.runs;

      await scoreProvider.recordRuns(0);

      expect(scoreProvider.currentMatch!.battingTeam.runs, initialRuns);
      final currentBalls = CricketScoreUtils.oversToBalls(scoreProvider.currentMatch!.battingTeam.overs);
      final expectedBalls = CricketScoreUtils.oversToBalls(initialOvers) + 1;
      expect(currentBalls, expectedBalls);
    });

    test('Records single run and rotates strike', () async {
      final initialStriker = scoreProvider.currentMatch!.striker?.name;
      final initialNonStriker = scoreProvider.currentMatch!.nonStriker?.name;

      await scoreProvider.recordRuns(1);

      // Strike should have rotated on odd runs
      expect(scoreProvider.currentMatch!.striker?.name, initialNonStriker);
      expect(scoreProvider.currentMatch!.nonStriker?.name, initialStriker);
    });

    test('Records boundary four without rotating strike', () async {
      final initialStriker = scoreProvider.currentMatch!.striker?.name;
      final initialNonStriker = scoreProvider.currentMatch!.nonStriker?.name;
      final initialRuns = scoreProvider.currentMatch!.battingTeam.runs;

      await scoreProvider.recordRuns(4);

      expect(scoreProvider.currentMatch!.battingTeam.runs, initialRuns + 4);
      expect(scoreProvider.currentMatch!.striker?.name, initialStriker);
      expect(scoreProvider.currentMatch!.nonStriker?.name, initialNonStriker);
    });

    test('Records wide ball without advancing legal balls', () async {
      final initialOvers = scoreProvider.currentMatch!.battingTeam.overs;
      final initialRuns = scoreProvider.currentMatch!.battingTeam.runs;

      await scoreProvider.recordExtra('wide');

      expect(scoreProvider.currentMatch!.battingTeam.runs, initialRuns + 1);
      expect(scoreProvider.currentMatch!.battingTeam.overs, initialOvers);
    });

    test('Undo last ball restores previous score and overs', () async {
      final initialRuns = scoreProvider.currentMatch!.battingTeam.runs;
      final initialOvers = scoreProvider.currentMatch!.battingTeam.overs;

      await scoreProvider.recordRuns(6);
      expect(scoreProvider.currentMatch!.battingTeam.runs, initialRuns + 6);
      expect(scoreProvider.canUndo, isTrue);

      await scoreProvider.undo();

      expect(scoreProvider.currentMatch!.battingTeam.runs, initialRuns);
      expect(scoreProvider.currentMatch!.battingTeam.overs, initialOvers);
    });
  });
}
