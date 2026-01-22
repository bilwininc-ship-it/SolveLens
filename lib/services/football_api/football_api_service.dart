import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class FootballApiService {
  late final ApiClient _client;

  FootballApiService() {
    _client = ApiClient(
      baseUrl: AppConstants.footballApiBaseUrl,
      defaultHeaders: {
        'x-apisports-key': AppConstants.footballApiKey,
      },
    );
  }

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