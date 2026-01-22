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
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    final response = await _model.generateContent(content);
    return response.text ?? 'Analiz yapılamadı';
  }

  Future<String> analyzeText(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'Yanıt alınamadı';
  }
}