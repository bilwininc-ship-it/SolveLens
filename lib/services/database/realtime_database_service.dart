// Firebase Realtime Database Service for question history
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/question.dart';
import '../../data/models/question_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database;
  
  RealtimeDatabaseService(this._database);

  /// Saves question to Realtime Database (TEXT ONLY, NO IMAGES)
  /// Path: users/{uid}/history/{questionId}
  Future<void> saveQuestionHistory({
    required String userId,
    required Question question,
  }) async {
    try {
      final ref = _database.ref('users/$userId/history/${question.id}');
      
      // Save ONLY text data, NO images
      await ref.set({
        'question': question.question,
        'answer': question.answer,
        'subject': question.subject,
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw RealtimeDatabaseException('Failed to save question history: $e');
    }
  }

  /// Retrieves question history from Realtime Database
  /// Returns list sorted by date (newest first)
  Future<List<Question>> getQuestionHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final ref = _database.ref('users/$userId/history');
      
      // Query with ordering and limit
      final snapshot = await ref
          .orderByChild('createdAt')
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final questions = <Question>[];

      data.forEach((key, value) {
        final questionData = value as Map<dynamic, dynamic>;
        questions.add(QuestionModel(
          id: key.toString(),
          userId: userId,
          imageUrl: '', // No image URL stored
          question: questionData['question'] ?? '',
          answer: questionData['answer'] ?? '',
          subject: questionData['subject'] ?? 'General',
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            questionData['createdAt'] as int,
          ),
        ));
      });

      // Sort by date descending (newest first)
      questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return questions;
    } catch (e) {
      throw RealtimeDatabaseException('Failed to retrieve question history: $e');
    }
  }

  /// Deletes a specific question from history
  Future<void> deleteQuestion({
    required String userId,
    required String questionId,
  }) async {
    try {
      final ref = _database.ref('users/$userId/history/$questionId');
      await ref.remove();
    } catch (e) {
      throw RealtimeDatabaseException('Failed to delete question: $e');
    }
  }

  /// Clears all history for a user
  Future<void> clearHistory({required String userId}) async {
    try {
      final ref = _database.ref('users/$userId/history');
      await ref.remove();
    } catch (e) {
      throw RealtimeDatabaseException('Failed to clear history: $e');
    }
  }
}

/// Custom exception for Realtime Database errors
class RealtimeDatabaseException implements Exception {
  final String message;
  RealtimeDatabaseException(this.message);
  
  @override
  String toString() => message;
}
