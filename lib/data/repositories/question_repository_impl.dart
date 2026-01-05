// Repository implementation for question analysis (Data Layer)
// Updated to use Firebase Realtime Database
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../../services/ai/ai_service.dart';
import '../../services/database/realtime_database_service.dart';
import '../models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final AIService aiService;
  final RealtimeDatabaseService databaseService;

  QuestionRepositoryImpl({
    required this.aiService,
    required this.databaseService,
  });

  @override
  Future<Either<Failure, Question>> analyzeQuestion({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Analyze question using AI service
      final result = await aiService.analyzeQuestion(imageFile);
      
      // Create question entity (NO IMAGE URL stored)
      final question = QuestionModel(
        id: const Uuid().v4(),
        userId: userId,
        imageUrl: '', // NO IMAGE stored in database
        question: result['question']!,
        answer: result['solution']!,
        createdAt: DateTime.now(),
        subject: result['subject']!,
      );

      // Save to Realtime Database (fire and forget, TEXT ONLY)
      _saveToDatabase(question).ignore();

      return Right(question);
      
    } on AIServiceException catch (e) {
      if (e.isRateLimitError) {
        return Left(SubscriptionFailure(e.message));
      } else if (e.isBlurryImage) {
        return Left(CacheFailure(e.message));
      } else {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to analyze question: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final questions = await databaseService.getQuestionHistory(
        userId: userId,
        limit: limit,
      );

      return Right(questions);
    } catch (e) {
      return Left(ServerFailure('Failed to retrieve history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuestion({
    required Question question,
  }) async {
    try {
      await _saveToDatabase(question);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save question: $e'));
    }
  }

  /// Internal method to save question to Realtime Database (TEXT ONLY)
  Future<void> _saveToDatabase(Question question) async {
    await databaseService.saveQuestionHistory(
      userId: question.userId,
      question: question,
    );
  }
}
