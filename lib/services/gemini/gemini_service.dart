import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_constants.dart';
import '../../features/analysis/data/models/match_model.dart';
import '../../core/utils/logger.dart';
import 'dart:convert';

/// Gemini AI Service
/// Handles AI-powered image analysis and text generation
class GeminiService {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;

  GeminiService() {
    // Gemini 1.5 Flash for Vision (Image Analysis)
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );

    // Gemini 1.5 Flash for Text
    _textModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// Extract football matches from bulletin image using OCR
  /// Returns a list of MatchModel objects
  Future<List<MatchModel>> extractMatches(Uint8List imageBytes) async {
    try {
      Logger.log('Starting Gemini OCR extraction...');

      // Create the system prompt for match extraction
      const prompt = '''
You are a sports betting expert. Analyze this football bulletin image and extract the home team, away team, and match date.

Rules:
1. Extract ONLY valid football matches
2. Return the output as a valid JSON array
3. Format: [{"home": "Team A", "away": "Team B", "date": "2024-05-20"}]
4. Use ISO date format (YYYY-MM-DD)
5. Do not include any other text, explanation, or markdown
6. If no matches found, return empty array: []

Return ONLY the JSON array, nothing else.''';

      // Create content with image and prompt
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate content from Gemini
      final response = await _visionModel.generateContent(content);
      final responseText = response.text ?? '';

      Logger.log('Gemini response received: $responseText');

      // Clean the response (remove markdown code blocks if present)
      String cleanedResponse = responseText.trim();
      
      // Remove markdown code blocks
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.replaceAll('```', '').trim();
      }

      // Parse JSON
      final List<dynamic> jsonData = jsonDecode(cleanedResponse);
      
      // Convert to MatchModel list
      final matches = jsonData
          .map((json) {
            try {
              return MatchModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              Logger.error('Failed to parse match: $json', error: e);
              return null;
            }
          })
          .whereType<MatchModel>() // Filter out nulls
          .toList();

      Logger.log('Successfully extracted ${matches.length} matches');
      return matches;
    } catch (e) {
      Logger.error('Gemini OCR extraction failed', error: e);
      
      // Check for specific errors
      if (e.toString().contains('API_KEY')) {
        throw Exception('Invalid Gemini API Key. Please check your configuration.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Failed to parse response. Please try with a clearer image.');
      } else {
        throw Exception('Analysis failed: ${e.toString()}');
      }
    }
  }

  /// Analyze image with custom prompt (legacy support)
  Future<String> analyzeImage(List<int> imageBytes, String prompt) async {
    try {
      final uint8ImageBytes = Uint8List.fromList(imageBytes);
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', uint8ImageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Analysis failed';
    } catch (e) {
      Logger.error('Image analysis failed', error: e);
      return 'Analysis failed: ${e.toString()}';
    }
  }

  /// Analyze text with Gemini (for future predictions)
  Future<String> analyzeText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _textModel.generateContent(content);
      return response.text ?? 'No response received';
    } catch (e) {
      Logger.error('Text analysis failed', error: e);
      return 'Analysis failed: ${e.toString()}';
    }
  }
}