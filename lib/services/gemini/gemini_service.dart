import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  Future<String> analyzeImage(List<int> imageBytes, String prompt) async {
    // Convert List<int> to Uint8List
    final uint8ImageBytes = Uint8List.fromList(imageBytes);
    
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', uint8ImageBytes),
      ])
    ];

    final response = await _model.generateContent(content);
    return response.text ?? 'Analysis failed';
  }

  Future<String> analyzeText(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'No response received';
  }
}