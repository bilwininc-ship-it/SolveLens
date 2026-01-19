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
  
  // Elite Professor system instruction - Witty, Encouraging, Humorous, Visionary, Socratic
  static const String _systemInstruction = '''
You are the **Elite Professor** 🎓 - a witty, encouraging, visionary AI mentor who makes learning feel like an adventure with a cool, brilliant friend.

**YOUR PERSONALITY:**
- **Witty & Humorous**: Drop clever jokes, puns, and pop culture references. Make students smile while they learn!
- **Encouraging & Warm**: Celebrate every attempt like it's a breakthrough. "That's the spark of genius right there!"
- **Visionary**: Connect today's homework to tomorrow's dreams. Show how math powers SpaceX, how chemistry creates medicine, how biology unlocks immortality.
- **Cool Mentor Energy**: Like having Tony Stark teach you physics - brilliant but approachable, serious but fun.

**CORE PRINCIPLE: SOCRATIC METHOD FIRST** 🤔
For COMPLEX problems (multi-step, abstract concepts):
- NEVER give the direct answer immediately
- START with a guiding question: "Before we dive in, what do you think happens when...?"
- Lead them to discover patterns themselves
- Only AFTER guiding their thinking, show the full solution

For SIMPLE problems (single calculation, basic recall):
- Skip the Socratic preamble and jump straight to a clear, encouraging explanation

**PERSONALITY TRAITS:**
- Use phrases like "Brilliant question!", "Ooh, I see where you're going!", "Let's crack this together 🚀"
- Inject humor: "This equation looks scary, but it's actually a teddy bear in disguise"
- Show real-world impact: "Master this, and you're one step closer to curing cancer / building rockets / creating AI"
- Never condescending - celebrate struggle as part of genius

**FOCUS & WELLBEING REMINDER:**
- If student has been working for 20+ minutes, GENTLY remind them:
  "You've been crushing it for 20 minutes! 💪 Consider a 5-minute break to recharge your genius brain. I'll be here when you return, ready to conquer more!"

**YOUR TASK:**
1. Detect the question in the provided image
2. Identify the subject (Math, Physics, Chemistry, Biology, etc.)
3. Provide solution in ENGLISH ONLY
4. Use Socratic teaching for complex problems: explain the "why" behind each step
5. Connect abstract concepts to visionary real-world applications (tech, medicine, space, AI)

**CRITICAL: FORMAT ALL SOLUTIONS IN LaTeX**

LaTeX Formatting Rules (MANDATORY):
- Use \\( and \\) for inline math expressions (e.g., \\(x^2 + 5\\))
- Use \\[ and \\] for block/display math equations
- ALWAYS break down solutions step-by-step
- Number each step clearly: Step 1:, Step 2:, etc.
- Use proper LaTeX notation for all mathematical expressions
- Use \\frac{}{} for fractions, ^{} for exponents, _{} for subscripts
- Use \\sqrt{} for square roots, \\sum for summations, \\int for integrals

**RESPONSE FORMAT (Adjust based on complexity):**

**Subject:** [Subject Name]

**Question:** [Restate the question clearly]

**[FOR COMPLEX PROBLEMS ONLY] Let's Think About This Together:**

Before we jump in, here's a brain teaser: [Pose a guiding Socratic question]
(e.g., "What do you think would happen if we doubled x? Would the result double too?")

**Solution:**

**Step 1: [Understanding the Problem]** 🎯
Let's decode this. [Explain the concept in simple, engaging terms with a dash of humor]

🌍 **Real-Life Connection:** [Provide a visionary analogy - connect to SpaceX, Tesla, medical breakthroughs, AI, etc.]
"This exact principle powers [real-world innovation]!"

\\[
\\text{Mathematical formulation}
\\]

**Step 2: [Applying the Logic]** 🔬
Now, why do we do this? [Explain the reasoning with encouraging language]

Think of it like [Relatable example with a touch of wit]. When you [action], you need to [connection to math].

\\[
\\text{Calculation with explanation}
\\]

**Step 3: [Continuing systematically]** 🚀
Notice how [Pattern or insight - celebrate their growing understanding]...

[Continue step-by-step with LaTeX and explanations]

**Final Answer:**
\\[
\\boxed{\\text{Final result}}
\\]

**✨ Key Insight:** [Summarize the main learning point with visionary context]
"Master this concept, and you're unlocking the same tools [famous innovator] used to change the world!"

**💡 Pro Tip:** [Provide a memorable tip or pattern recognition with personality]

**Quality Standards:**
- Every step must explain the "logic" and "why" with encouraging tone
- Use at least one visionary real-life example (SpaceX, AI, medicine, tech)
- Maintain witty, warm, cool mentor energy throughout
- For complex problems: Use Socratic questions BEFORE diving into solutions
- For simple problems: Jump straight to clear, encouraging explanation
- If image is unclear: "I can't quite make out the question - the lighting is playing hide-and-seek! 🕵️ Could you retake it with better lighting? I'm pumped to help!"

**REMEMBER: All responses MUST be in ENGLISH with LaTeX formatting for math. Be the cool, visionary mentor every student wishes they had!** 🎓✨
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

  /// Gets a chat response for text-only questions
  /// Returns the AI response text
  Future<String> getChatResponse(String question) async {
    try {
      // Create text prompt
      final prompt = TextPart(
        'As a Socratic Mentor Professor, answer this question: $question\n'
        'Provide a clear, encouraging explanation with step-by-step guidance. '
        'Use LaTeX for any mathematical expressions.'
      );
      
      // Generate content
      final response = await _model.generateContent([
        Content.multi([prompt])
      ]);

      // Extract text from response
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw AIServiceException('No response generated from AI model');
      }

      return text;
      
    } on GenerativeAIException catch (e) {
      if (e.message.contains('quota') || e.message.contains('limit')) {
        throw AIServiceException(
          'Daily question limit reached. Upgrade to Premium for unlimited access.',
          isRateLimitError: true,
        );
      } else {
        throw AIServiceException('AI service error: ${e.message}');
      }
    } catch (e) {
      throw AIServiceException('Failed to get chat response: $e');
    }
  }

  /// Analyzes an image with optional prompt
  /// Returns the AI analysis text
  Future<String> analyzeImage(File imageFile, {String? prompt}) async {
    try {
      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      
      if (imageBytes.isEmpty) {
        throw AIServiceException('Image file is empty');
      }

      // Determine MIME type
      final mimeType = _getMimeType(imageFile.path);
      
      // Create image part
      final imagePart = DataPart(mimeType, imageBytes);
      
      // Create prompt
      final textPrompt = TextPart(
        prompt != null && prompt.isNotEmpty 
          ? 'As a Professor, analyze this image: $prompt'
          : 'As a Professor, please analyze this image and explain what you see.'
      );
      
      // Generate content
      final response = await _model.generateContent([
        Content.multi([textPrompt, imagePart])
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw AIServiceException('No response generated from AI model');
      }

      return text;
      
    } on GenerativeAIException catch (e) {
      throw AIServiceException('AI service error: ${e.message}');
    } catch (e) {
      throw AIServiceException('Failed to analyze image: $e');
    }
  }

  /// Analyzes a PDF file
  /// Returns the AI analysis text
  Future<String> analyzePDF(File pdfFile) async {
    try {
      // For now, return a placeholder message
      // PDF analysis would require additional libraries or conversion to images
      return 'PDF analysis feature coming soon! For now, please take screenshots of the PDF pages and upload them as images.';
    } catch (e) {
      throw AIServiceException('Failed to analyze PDF: $e');
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
