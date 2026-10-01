class TeamModel {
  final String id;
  final String name;
  final String shortCode;
  final String flagEmoji;
  int runs;
  int wickets;
  double overs;
  bool isBatting;
  List<String> playerIds;

  TeamModel({
    required this.id,
    required this.name,
    required this.shortCode,
    this.flagEmoji = '🏏',
    this.runs = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.isBatting = false,
    this.playerIds = const [],
  });

  String get scoreDisplay => '$runs/$wickets';
  String get oversDisplay => '(${overs.toStringAsFixed(1)} ov)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortCode': shortCode,
      'flagEmoji': flagEmoji,
      'runs': runs,
      'wickets': wickets,
      'overs': overs,
      'isBatting': isBatting,
      'playerIds': playerIds,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map, [String? fallbackId]) {
    return TeamModel(
      id: map['id'] ?? fallbackId ?? '',
      name: map['name'] ?? '',
      shortCode: map['shortCode'] ?? '',
      flagEmoji: map['flagEmoji'] ?? '🏏',
      runs: (map['runs'] as num?)?.toInt() ?? 0,
      wickets: (map['wickets'] as num?)?.toInt() ?? 0,
      overs: (map['overs'] as num?)?.toDouble() ?? 0.0,
      isBatting: map['isBatting'] ?? false,
      playerIds: List<String>.from(map['playerIds'] ?? []),
    );
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? shortCode,
    String? flagEmoji,
    int? runs,
    int? wickets,
    double? overs,
    bool? isBatting,
    List<String>? playerIds,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      isBatting: isBatting ?? this.isBatting,
      playerIds: playerIds ?? this.playerIds,
    );
  }
}
