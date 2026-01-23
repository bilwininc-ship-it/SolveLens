/// Match Model
/// Represents a single football match extracted from bulletin image
class MatchModel {
  final String home;
  final String away;
  final String date;

  MatchModel({
    required this.home,
    required this.away,
    required this.date,
  });

  /// Create MatchModel from JSON
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      home: json['home']?.toString() ?? '',
      away: json['away']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }

  /// Convert MatchModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'home': home,
      'away': away,
      'date': date,
    };
  }

  /// Create a copy with modified fields
  MatchModel copyWith({
    String? home,
    String? away,
    String? date,
  }) {
    return MatchModel(
      home: home ?? this.home,
      away: away ?? this.away,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'MatchModel(home: $home, away: $away, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchModel &&
        other.home == home &&
        other.away == away &&
        other.date == date;
  }

  @override
  int get hashCode => home.hashCode ^ away.hashCode ^ date.hashCode;
}