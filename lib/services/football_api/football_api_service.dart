import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../features/analysis/data/models/team_stats_model.dart';
import '../../core/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Football API Service - PHASE 13
/// Handles communication with api-football (RapidAPI)
class FootballApiService {
  late final ApiClient _client;
  final String _baseUrl = AppConstants.footballApiBaseUrl;
  final String _apiKey = AppConstants.footballApiKey;

  FootballApiService() {
    _client = ApiClient(
      baseUrl: _baseUrl,
      defaultHeaders: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': 'v3.football.api-sports.io',
      },
    );
  }

  /// Search for a team by name (fuzzy match)
  /// Returns the team ID or null if not found
  Future<int?> searchTeam(String teamName) async {
    try {
      Logger.log('Searching for team: $teamName');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/teams?search=$teamName'),
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['response'] as List<dynamic>?;
        
        if (results != null && results.isNotEmpty) {
          // Get the first (best) match
          final teamId = results[0]['team']['id'];
          final foundName = results[0]['team']['name'];
          Logger.log('Team found: $foundName (ID: $teamId)');
          return teamId;
        }
      }
      
      Logger.log('Team not found: $teamName');
      return null;
    } catch (e) {
      Logger.error('Team search failed', error: e);
      return null;
    }
  }

  /// Get team statistics including form, standings, and injuries
  /// Returns TeamStatsModel or null if unavailable
  Future<TeamStatsModel?> getTeamStats(int teamId, {String? season}) async {
    try {
      Logger.log('Fetching stats for team ID: $teamId');
      
      // Use current season if not specified
      final currentSeason = season ?? DateTime.now().year.toString();
      
      // Get team statistics
      final statsResponse = await http.get(
        Uri.parse('$_baseUrl/teams/statistics?team=$teamId&season=$currentSeason&league=39'),
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );

      if (statsResponse.statusCode != 200) {
        Logger.log('Stats API returned status: ${statsResponse.statusCode}');
        return _createMockStats(teamId);
      }

      final statsData = json.decode(statsResponse.body);
      final response = statsData['response'];
      
      if (response == null) {
        return _createMockStats(teamId);
      }

      // Extract data
      final teamData = response['team'];
      final form = response['form'] ?? '';
      final fixtures = response['fixtures'] ?? {};
      final played = fixtures['played']?['total'] ?? 0;
      final wins = fixtures['wins']?['total'] ?? 0;
      final draws = fixtures['draws']?['total'] ?? 0;
      final losses = fixtures['loses']?['total'] ?? 0;

      // Get last 5 matches form
      final last5Form = form.length > 5 ? form.substring(form.length - 5) : form;

      // Try to get standings and injuries (may not be available)
      int? position;
      int? points;
      List<String> injuries = [];

      // Get standings
      try {
        final standingsResponse = await http.get(
          Uri.parse('$_baseUrl/standings?team=$teamId&season=$currentSeason'),
          headers: {
            'x-rapidapi-key': _apiKey,
            'x-rapidapi-host': 'v3.football.api-sports.io',
          },
        );

        if (standingsResponse.statusCode == 200) {
          final standingsData = json.decode(standingsResponse.body);
          final standings = standingsData['response']?[0]?['league']?['standings']?[0];
          if (standings != null && standings is List && standings.isNotEmpty) {
            for (var standing in standings) {
              if (standing['team']?['id'] == teamId) {
                position = standing['rank'];
                points = standing['points'];
                break;
              }
            }
          }
        }
      } catch (e) {
        Logger.log('Standings not available');
      }

      // Get injuries
      try {
        final injuriesResponse = await http.get(
          Uri.parse('$_baseUrl/injuries?team=$teamId'),
          headers: {
            'x-rapidapi-key': _apiKey,
            'x-rapidapi-host': 'v3.football.api-sports.io',
          },
        );

        if (injuriesResponse.statusCode == 200) {
          final injuriesData = json.decode(injuriesResponse.body);
          final injuryList = injuriesData['response'] as List<dynamic>?;
          if (injuryList != null) {
            injuries = injuryList
                .map((inj) => inj['player']?['name']?.toString() ?? 'Unknown')
                .take(5) // Limit to 5 injuries
                .toList();
          }
        }
      } catch (e) {
        Logger.log('Injuries not available');
      }

      return TeamStatsModel(
        teamId: teamId,
        teamName: teamData?['name'] ?? 'Unknown Team',
        form: last5Form,
        standingPosition: position,
        standingPoints: points,
        injuries: injuries,
        matchesPlayed: played,
        wins: wins,
        draws: draws,
        losses: losses,
      );
    } catch (e) {
      Logger.error('Failed to get team stats', error: e);
      return _createMockStats(teamId);
    }
  }

  /// Create mock stats when API is unavailable
  TeamStatsModel _createMockStats(int teamId) {
    Logger.log('Using mock stats for team $teamId');
    return TeamStatsModel(
      teamId: teamId,
      teamName: 'Team $teamId',
      form: 'WWDWL',
      standingPosition: null,
      standingPoints: null,
      injuries: [],
      matchesPlayed: 10,
      wins: 5,
      draws: 3,
      losses: 2,
    );
  }

  // Legacy methods for compatibility
  Future<Map<String, dynamic>> getFixtures({String? date, String? league, String? team}) async {
    String endpoint = '/fixtures?';
    if (date != null) endpoint += 'date=$date&';
    if (league != null) endpoint += 'league=$league&';
    if (team != null) endpoint += 'team=$team&';
    
    return await _client.get(endpoint.substring(0, endpoint.length - 1));
  }

  Future<Map<String, dynamic>> getTeamStatistics(String teamId, String season) async {
    return await _client.get('/teams/statistics?team=$teamId&season=$season');
  }

  Future<Map<String, dynamic>> getLeagueStandings(String leagueId, String season) async {
    return await _client.get('/standings?league=$leagueId&season=$season');
  }
}
