/// Team Statistics Model
/// Contains team stats from Football API
class TeamStatsModel {
  final int teamId;
  final String teamName;
  final String form; // Last 5 matches (e.g., "WWDLW")
  final int? standingPosition;
  final int? standingPoints;
  final List<String> injuries; // List of injured players
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;

  TeamStatsModel({
    required this.teamId,
    required this.teamName,
    required this.form,
    this.standingPosition,
    this.standingPoints,
    required this.injuries,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  /// Create TeamStatsModel from JSON
  factory TeamStatsModel.fromJson(Map<String, dynamic> json) {
    return TeamStatsModel(
      teamId: json['teamId'] ?? 0,
      teamName: json['teamName'] ?? '',
      form: json['form'] ?? '',
      standingPosition: json['standingPosition'],
      standingPoints: json['standingPoints'],
      injuries: (json['injuries'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'form': form,
      'standingPosition': standingPosition,
      'standingPoints': standingPoints,
      'injuries': injuries,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'draws': draws,
      'losses': losses,
    };
  }

  @override
  String toString() {
    return 'TeamStatsModel(teamName: $teamName, form: $form, position: $standingPosition)';
  }
}
