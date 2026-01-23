import 'dart:convert';
import '../../../services/gemini/gemini_service.dart';
import '../../../services/football_api/football_api_service.dart';
import '../data/models/match_model.dart';
import '../data/models/prediction_model.dart';
import '../data/models/team_stats_model.dart';
import '../../../core/utils/logger.dart';

/// AI Prediction Engine - PHASE 14
/// Analyzes match data and generates AI-powered predictions
class PredictionEngine {
  final GeminiService _geminiService = GeminiService();
  final FootballApiService _footballApiService = FootballApiService();

  /// Generate prediction for a match
  /// Returns PredictionModel with probabilities and reasoning
  Future<PredictionModel> predictMatch(MatchModel match) async {
    try {
      Logger.log('Starting prediction for: ${match.home} vs ${match.away}');

      // Step 1: Search for team IDs
      final homeTeamId = await _footballApiService.searchTeam(match.home);
      final awayTeamId = await _footballApiService.searchTeam(match.away);

      // Step 2: Get team statistics
      TeamStatsModel? homeStats;
      TeamStatsModel? awayStats;

      if (homeTeamId != null) {
        homeStats = await _footballApiService.getTeamStats(homeTeamId);
      }

      if (awayTeamId != null) {
        awayStats = await _footballApiService.getTeamStats(awayTeamId);
      }

      // Step 3: Build AI prompt with statistics
      final prompt = _buildPredictionPrompt(match, homeStats, awayStats);

      // Step 4: Get AI prediction
      final aiResponse = await _geminiService.analyzeText(prompt);

      // Step 5: Parse AI response
      final prediction = _parsePredictionResponse(aiResponse, match);

      Logger.log('Prediction generated successfully');
      return prediction;
    } catch (e) {
      Logger.error('Prediction failed', error: e);
      
      // Return fallback prediction
      return _createFallbackPrediction(match);
    }
  }

  /// Build the AI prompt with match data and statistics
  String _buildPredictionPrompt(
    MatchModel match,
    TeamStatsModel? homeStats,
    TeamStatsModel? awayStats,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are a professional football analyst. Analyze the following match and provide predictions.');
    buffer.writeln('');
    buffer.writeln('MATCH INFORMATION:');
    buffer.writeln('Home Team: ${match.home}');
    buffer.writeln('Away Team: ${match.away}');
    buffer.writeln('Date: ${match.date}');
    buffer.writeln('');

    // Add home team stats if available
    if (homeStats != null) {
      buffer.writeln('HOME TEAM STATISTICS:');
      buffer.writeln('Recent Form (Last 5): ${homeStats.form}');
      buffer.writeln('Matches Played: ${homeStats.matchesPlayed}');
      buffer.writeln('Record: ${homeStats.wins}W - ${homeStats.draws}D - ${homeStats.losses}L');
      if (homeStats.standingPosition != null) {
        buffer.writeln('League Position: ${homeStats.standingPosition} (${homeStats.standingPoints} points)');
      }
      if (homeStats.injuries.isNotEmpty) {
        buffer.writeln('Key Injuries: ${homeStats.injuries.join(", ")}');
      }
      buffer.writeln('');
    } else {
      buffer.writeln('HOME TEAM STATISTICS: Statistical data currently unavailable');
      buffer.writeln('');
    }

    // Add away team stats if available
    if (awayStats != null) {
      buffer.writeln('AWAY TEAM STATISTICS:');
      buffer.writeln('Recent Form (Last 5): ${awayStats.form}');
      buffer.writeln('Matches Played: ${awayStats.matchesPlayed}');
      buffer.writeln('Record: ${awayStats.wins}W - ${awayStats.draws}D - ${awayStats.losses}L');
      if (awayStats.standingPosition != null) {
        buffer.writeln('League Position: ${awayStats.standingPosition} (${awayStats.standingPoints} points)');
      }
      if (awayStats.injuries.isNotEmpty) {
        buffer.writeln('Key Injuries: ${awayStats.injuries.join(", ")}');
      }
      buffer.writeln('');
    } else {
      buffer.writeln('AWAY TEAM STATISTICS: Statistical data currently unavailable');
      buffer.writeln('');
    }

    buffer.writeln('REQUIRED OUTPUT:');
    buffer.writeln('Analyze these match statistics (Form, Standings, Injuries). Predict the probabilities (%) for Home Win, Draw, Away Win, Over/Under 2.5, and Both Teams to Score. Provide a brief professional reasoning for the highest probability outcome.');
    buffer.writeln('');
    buffer.writeln('Return your analysis as a valid JSON object with this exact structure:');
    buffer.writeln('{');
    buffer.writeln('  "homeWin": 45.5,');
    buffer.writeln('  "draw": 27.0,');
    buffer.writeln('  "awayWin": 27.5,');
    buffer.writeln('  "over25": 58.0,');
    buffer.writeln('  "under25": 42.0,');
    buffer.writeln('  "btts": 62.0,');
    buffer.writeln('  "bttsNo": 38.0,');
    buffer.writeln('  "reasoning": "Your professional analysis here (2-3 sentences)",');
    buffer.writeln('  "recommendedBet": "Home Win"');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('IMPORTANT:');
    buffer.writeln('- All probabilities must be numbers (not strings)');
    buffer.writeln('- Probabilities for each category must sum to 100%');
    buffer.writeln('- Return ONLY the JSON object, no markdown or additional text');
    buffer.writeln('- Reasoning should be concise and professional');
    buffer.writeln('- recommendedBet should be one of: "Home Win", "Draw", "Away Win", "Over 2.5", "Under 2.5", "Both Teams to Score", or "No BTTS"');

    return buffer.toString();
  }

  /// Parse AI response into PredictionModel
  PredictionModel _parsePredictionResponse(String response, MatchModel match) {
    try {
      Logger.log('Parsing AI response...');
      
      // Clean response (remove markdown if present)
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.replaceAll('```', '').trim();
      }

      // Parse JSON
      final Map<String, dynamic> data = json.decode(cleanedResponse);

      return PredictionModel(
        homeTeam: match.home,
        awayTeam: match.away,
        matchDate: match.date,
        homeWinProbability: (data['homeWin'] ?? 33.3).toDouble(),
        drawProbability: (data['draw'] ?? 33.3).toDouble(),
        awayWinProbability: (data['awayWin'] ?? 33.4).toDouble(),
        over25Probability: (data['over25'] ?? 50.0).toDouble(),
        under25Probability: (data['under25'] ?? 50.0).toDouble(),
        bttsProbability: (data['btts'] ?? 50.0).toDouble(),
        bttsNoProbability: (data['bttsNo'] ?? 50.0).toDouble(),
        reasoning: data['reasoning'] ?? 'Analysis based on available data.',
        recommendedBet: data['recommendedBet'] ?? 'Home Win',
      );
    } catch (e) {
      Logger.error('Failed to parse prediction response', error: e);
      return _createFallbackPrediction(match);
    }
  }

  /// Create fallback prediction when AI fails
  PredictionModel _createFallbackPrediction(MatchModel match) {
    Logger.log('Using fallback prediction');
    return PredictionModel(
      homeTeam: match.home,
      awayTeam: match.away,
      matchDate: match.date,
      homeWinProbability: 40.0,
      drawProbability: 30.0,
      awayWinProbability: 30.0,
      over25Probability: 55.0,
      under25Probability: 45.0,
      bttsProbability: 60.0,
      bttsNoProbability: 40.0,
      reasoning: 'Statistical data currently unavailable. Prediction based on general football patterns and home advantage factors.',
      recommendedBet: 'Home Win',
    );
  }
}
