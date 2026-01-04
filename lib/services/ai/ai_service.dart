// Gemini 2.0 Flash AI Service for question analysis
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'dart:typed_data';

class AIService {
  late final GenerativeModel _model;
  static const String _modelName = 'gemini-2.0-flash-exp';
  
  // System instruction for optimal question solving
  static const String _systemInstruction = '''
You are a professional global educator with expertise in all academic subjects.

Your task:
1. Detect the question in the provided image
2. Identify the subject (Math, Physics, Chemistry, Biology, etc.)
3. Detect the language of the question automatically
4. Provide a comprehensive answer in the SAME LANGUAGE as the question
5. Format ALL mathematical expressions in LaTeX using proper delimiters

Response format:
- Use \\( and \\) for inline math (e.g., \\(x^2 + 5\\))
- Use \\[ and \\] for block math equations
- Break down the solution step-by-step
- Explain the logic behind each step
- Use clear headings: "Question:", "Subject:", "Solution:", "Step 1:", etc.

Quality standards:
- Be thorough but concise
- Use proper mathematical notation
- Maintain educational tone
- If image is unclear or contains no question, respond: "I cannot detect a clear question in this image. Please ensure the image is well-lit and the text is readable."

Language detection:
- English question  English answer
- Turkish question › Turkish answer
- Spanish question › Spanish answer
- Automatically adapt to any language detected
''';

  /// Initializes the AI service with API key
  AIService(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.4, // Lower temperature for more focused responses
        topK: 32,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  /// Analyzes a question image and returns detailed solution
  /// Throws AIServiceException on failure
  Future<Map<String, String>> analyzeQuestion(File imageFile) async {
    Uint8List? imageBytes;
    
    try {
      // Read image file
      imageBytes = await imageFile.readAsBytes();
      
      // Validate image size
      if (imageBytes.isEmpty) {
        throw AIServiceException('Image file is empty');
      }

      // Determine MIME type
      final mimeType = _getMimeType(imageFile.path);
      
      // Create image part
      final imagePart = DataPart(mimeType, imageBytes);
      
      // Create prompt
      final prompt = TextPart(
        'Analyze this homework question and provide a detailed step-by-step solution.'
      );
      
      // Generate content
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      // Extract text from response
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw AIServiceException('No response generated from AI model');
      }

      // Parse response
      return _parseAIResponse(text);
      
    } on GenerativeAIException catch (e) {
      // Handle API-specific errors
      if (e.message.contains('quota') || e.message.contains('limit')) {
        throw AIServiceException(
          'Daily question limit reached. Upgrade to Premium for unlimited access.',
          isRateLimitError: true,
        );
      } else if (e.message.contains('SAFETY')) {
        throw AIServiceException(
          'Content policy violation. Please ensure the image contains appropriate educational content.',
        );
      } else {
        throw AIServiceException('AI service error: ');
      }
    } catch (e) {
      throw AIServiceException('Failed to analyze question: ');
    } finally {
      // Clean up memory
      imageBytes = null;
    }
  }

  /// Determines MIME type from file extension
  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Parses AI response into structured format
  Map<String, String> _parseAIResponse(String response) {
    // Extract subject if mentioned
    String subject = 'General';
    final subjectMatch = RegExp(r'Subject:\s*(.+)', caseSensitive: false)
        .firstMatch(response);
    if (subjectMatch != null) {
      subject = subjectMatch.group(1)?.trim() ?? 'General';
    }

    // Extract question if mentioned
    String question = '';
    final questionMatch = RegExp(r'Question:\s*(.+?)(?=\n|Solution:|$)', 
        caseSensitive: false, dotAll: true).firstMatch(response);
    if (questionMatch != null) {
      question = questionMatch.group(1)?.trim() ?? '';
    }

    // Check if image is unclear
    if (response.contains('cannot detect') || 
        response.contains('unclear') ||
        response.contains('no question')) {
      throw AIServiceException(
        'Cannot detect a clear question in the image. Please ensure good lighting and readable text.',
        isBlurryImage: true,
      );
    }

    return {
      'subject': subject,
      'question': question.isNotEmpty ? question : 'Question extracted from image',
      'solution': response,
    };
  }

  /// Disposes resources (call when service is no longer needed)
  void dispose() {
    // Gemini SDK handles cleanup internally
  }
}

/// Custom exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final bool isRateLimitError;
  final bool isBlurryImage;

  AIServiceException(
    this.message, {
    this.isRateLimitError = false,
    this.isBlurryImage = false,
  });

  @override
  String toString() => message;
}
