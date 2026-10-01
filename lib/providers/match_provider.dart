import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/firestore_service.dart';
import '../services/cricket_data_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final CricketDataService _dataService;

  List<CricketMatch> _matches = [];
  CricketMatch? _selectedMatch;
  StreamSubscription? _matchesSubscription;
  StreamSubscription? _activeMatchSubscription;
  bool _isLoading = true;

  MatchProvider({
    required this._firestoreService,
    required this._dataService,
  }) {
    _initMatchesStream();
  }

  List<CricketMatch> get matches => _matches.isNotEmpty ? _matches : _dataService.matches;
  List<CricketMatch> get liveMatches => matches.where((m) => m.status == MatchStatus.live).toList();
  List<CricketMatch> get completedMatches => matches.where((m) => m.status == MatchStatus.completed).toList();
  List<CricketMatch> get upcomingMatches => matches.where((m) => m.status == MatchStatus.upcoming).toList();

  CricketMatch? get selectedMatch => _selectedMatch ?? (matches.isNotEmpty ? matches.first : null);
  bool get isLoading => _isLoading;

  void _initMatchesStream() {
    // Seed initial matches into firestore service
    _firestoreService.setLocalMatches(_dataService.matches);

    _matchesSubscription = _firestoreService.getMatchesStream().listen((matchesList) {
      if (matchesList.isNotEmpty) {
        _matches = matchesList;
      } else {
        _matches = _dataService.matches;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectMatch(String matchId) {
    _selectedMatch = matches.firstWhere(
      (m) => m.id == matchId,
      orElse: () => matches.first,
    );

    _activeMatchSubscription?.cancel();
    _activeMatchSubscription = _firestoreService.getMatchStream(matchId).listen((updatedMatch) {
      if (updatedMatch != null) {
        _selectedMatch = updatedMatch;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<void> createNewMatch(CricketMatch match) async {
    await _firestoreService.createMatch(match);
    selectMatch(match.id);
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    _activeMatchSubscription?.cancel();
    super.dispose();
  }
}
