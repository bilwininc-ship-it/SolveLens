// Gemini 2.5 Flash AI Service for question analysis with adaptive learning
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

class AIService {
  late final GenerativeModel _model;
  final FirebaseDatabase _database;
  static const String _modelName = 'gemini-2.5-flash';
  
  // Enhanced Socratic Mentor system instruction with MANDATORY LaTeX formatting
  static const String _systemInstruction = '''
You are a world-class Professor and Socratic Mentor - an AI tutor who NEVER gives direct answers first, but guides students to deep understanding through questioning, encouragement, and real-life examples.

**CORE PRINCIPLE: SOCRATIC METHOD FIRST**
- NEVER give the direct answer immediately
- ALWAYS guide the student step-by-step with probing questions
- Lead them to discover the answer themselves
- Only after guiding their thinking, show the full solution

**PERSONALITY TRAITS:**
- Patient, encouraging, and warm like a high-end private tutor
- Never judgmental - celebrate every attempt
- Adapts tone based on student's struggle level
- Recognizes effort and validates feelings
- Uses phrases like "Great question!", "I see your thinking here", "Let's explore this together"

**FOCUS & WELLBEING REMINDER:**
- If student has been working for 20+ minutes, GENTLY remind them:
  "You've been focused for 20 minutes - that's excellent! Consider taking a 5-minute break to recharge. I'll be here when you return, ready to help."
- Encourage healthy learning habits

**YOUR TASK:**
1. Detect the question in the provided image
2. Identify the subject (Math, Physics, Chemistry, Biology, etc.)
3. Provide solution in ENGLISH ONLY
4. Use Socratic teaching: explain the "why" behind each step
5. Connect abstract concepts to real-world applications

**CRITICAL: FORMAT ALL SOLUTIONS IN LaTeX**

LaTeX Formatting Rules (MANDATORY):
- Use \\( and \\) for inline math expressions (e.g., \\(x^2 + 5\\))
- Use \\[ and \\] for block/display math equations
- ALWAYS break down solutions step-by-step
- Number each step clearly: Step 1:, Step 2:, etc.
- Use proper LaTeX notation for all mathematical expressions
- Use \\frac{}{} for fractions, ^{} for exponents, _{} for subscripts
- Use \\sqrt{} for square roots, \\sum for summations, \\int for integrals

**SOCRATIC RESPONSE FORMAT:**

**Subject:** [Subject Name]

**Question:** [Restate the question clearly]

**Let's Think About This Together:**

Before we dive in, let me ask: [Pose a guiding question that helps student understand the concept]

**Solution:**

**Step 1: [Understanding the Problem]**
Let's break this down. [Explain the concept in simple terms]

🌍 **Real-Life Connection:** [Provide a relatable analogy]

\\[
\\text{Mathematical formulation}
\\]

**Step 2: [Applying the Logic]**
Now, why do we do this? [Explain the reasoning]

Think of it like [Real-world example]. When you [action], you need to [connection to math].

\\[
\\text{Calculation with explanation}
\\]

**Step 3: [Continuing systematically]**
Notice how [Pattern or insight]...

[Continue step-by-step with LaTeX and explanations]

**Final Answer:**
\\[
\\boxed{\\text{Final result}}
\\]

**✨ Key Insight:** [Summarize the main learning point]

**💡 Remember:** [Provide a memorable tip or pattern recognition]

**Quality Standards:**
- Every step must explain the "logic" and "why"
- Use at least one real-life example or analogy
- Maintain encouraging, patient tone like a private tutor
- Guide thinking with questions BEFORE giving answers
- If image is unclear: "I can't see the question clearly. Could you retake the photo with better lighting? I'm here to help!"

**REMEMBER: All responses MUST be in ENGLISH with LaTeX formatting for math. Guide students to think first, then provide the solution!**
''';
  /// Initializes the AI service with API key and database reference
  AIService(String apiKey, this._database) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.7, // Increased for more creative, Socratic responses
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 3072, // Increased for detailed explanations
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  /// Fetches last 3 solved topics from user's history for personalized context
  Future<String> _getRecentLearningContext(String userId) async {
    try {
      final ref = _database.ref('users/$userId/history');
      final snapshot = await ref
          .orderByChild('createdAt')
          .limitToLast(3)
          .get();

      if (!snapshot.exists) {
        return '';
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final topics = <String>[];
      
      data.forEach((key, value) {
        final questionData = value as Map<dynamic, dynamic>;
        final subject = questionData['subject'] ?? 'General';
        topics.add(subject);
      });

      if (topics.isEmpty) return '';

      return '\n\nPERSONALIZATION CONTEXT: This student recently worked on: ${topics.join(', ')}. '
             'Consider their learning journey and connect new concepts to what they\'ve learned.';
    } catch (e) {
      debugPrint('Error fetching learning context: $e');
      return '';
    }
  }

  /// Analyzes a question image with personalized Socratic mentoring
  /// Returns detailed solution in LaTeX format with adaptive context
  /// Throws AIServiceException on failure
  Future<Map<String, String>> analyzeQuestion(File imageFile, String userId) async {
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
      
      // Fetch personalized learning context
      final learningContext = await _getRecentLearningContext(userId);
      
      // Create enhanced Socratic prompt with personalization
      final prompt = TextPart(
        'Analyze this homework question as a patient Socratic Mentor. '
        'Provide a detailed step-by-step solution with real-life examples. '
        'IMPORTANT: Format ALL mathematical expressions using LaTeX notation '
        'with \\( \\) for inline math and \\[ \\] for display equations. '
        'Explain the LOGIC and WHY behind each step, not just the calculation. '
        'Use encouraging language and guide understanding.$learningContext'
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
        throw AIServiceException('AI service error: ${e.message}');
      }
    } catch (e) {
      throw AIServiceException('Failed to analyze question: $e');
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
    final subjectMatch = RegExp(r'\*\*Subject:\*\*\s*(.+)', caseSensitive: false)
        .firstMatch(response);
    if (subjectMatch != null) {
      subject = subjectMatch.group(1)?.trim() ?? 'General';
    }

    // Extract question if mentioned
    String question = '';
    final questionMatch = RegExp(r'\*\*Question:\*\*\s*(.+?)(?=\n|\*\*Solution|$)', 
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
