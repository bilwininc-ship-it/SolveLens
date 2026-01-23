/// Prediction Model
/// Contains AI-generated match predictions and probabilities
class PredictionModel {
  final String homeTeam;
  final String awayTeam;
  final String matchDate;
  
  // 1X2 Probabilities
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;
  
  // Over/Under 2.5 Goals
  final double over25Probability;
  final double under25Probability;
  
  // Both Teams to Score
  final double bttsProbability;
  final double bttsNoProbability;
  
  // AI Reasoning
  final String reasoning;
  final String recommendedBet;

  PredictionModel({
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDate,
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
    required this.over25Probability,
    required this.under25Probability,
    required this.bttsProbability,
    required this.bttsNoProbability,
    required this.reasoning,
    required this.recommendedBet,
  });

  /// Create from JSON
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      matchDate: json['matchDate'] ?? '',
      homeWinProbability: (json['homeWinProbability'] ?? 0).toDouble(),
      drawProbability: (json['drawProbability'] ?? 0).toDouble(),
      awayWinProbability: (json['awayWinProbability'] ?? 0).toDouble(),
      over25Probability: (json['over25Probability'] ?? 0).toDouble(),
      under25Probability: (json['under25Probability'] ?? 0).toDouble(),
      bttsProbability: (json['bttsProbability'] ?? 0).toDouble(),
      bttsNoProbability: (json['bttsNoProbability'] ?? 0).toDouble(),
      reasoning: json['reasoning'] ?? '',
      recommendedBet: json['recommendedBet'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'matchDate': matchDate,
      'homeWinProbability': homeWinProbability,
      'drawProbability': drawProbability,
      'awayWinProbability': awayWinProbability,
      'over25Probability': over25Probability,
      'under25Probability': under25Probability,
      'bttsProbability': bttsProbability,
      'bttsNoProbability': bttsNoProbability,
      'reasoning': reasoning,
      'recommendedBet': recommendedBet,
    };
  }

  /// Get highest probability outcome for 1X2
  String get mostLikelyOutcome {
    if (homeWinProbability >= drawProbability && homeWinProbability >= awayWinProbability) {
      return 'Home Win';
    } else if (drawProbability >= homeWinProbability && drawProbability >= awayWinProbability) {
      return 'Draw';
    } else {
      return 'Away Win';
    }
  }

  @override
  String toString() {
    return 'PredictionModel($homeTeam vs $awayTeam - $mostLikelyOutcome)';
  }
}
