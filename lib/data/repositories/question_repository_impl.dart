// Repository implementation for question analysis (Data Layer)
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../../services/ai/ai_service.dart';
import '../models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final AIService aiService;
  final FirebaseFirestore firestore;

  QuestionRepositoryImpl({
    required this.aiService,
    required this.firestore,
  });

  @override
  Future<Either<Failure, Question>> analyzeQuestion({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Analyze question using AI service
      final result = await aiService.analyzeQuestion(imageFile);
      
      // Create question entity
      final question = QuestionModel(
        id: const Uuid().v4(),
        userId: userId,
        imageUrl: imageFile.path, // TODO: Upload to Cloud Storage
        question: result['question']!,
        answer: result['solution']!,
        createdAt: DateTime.now(),
        subject: result['subject']!,
      );

      // Save to Firestore (fire and forget)
      _saveToFirestore(question).ignore();

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
      return Left(ServerFailure('Failed to analyze question: '));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await firestore
          .collection('questions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();

      return Right(questions);
    } catch (e) {
      return Left(ServerFailure('Failed to retrieve history: '));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuestion({
    required Question question,
  }) async {
    try {
      await _saveToFirestore(question);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save question: '));
    }
  }

  /// Internal method to save question to Firestore
  Future<void> _saveToFirestore(Question question) async {
    final model = QuestionModel.fromEntity(question);
    await firestore
        .collection('questions')
        .doc(question.id)
        .set(model.toFirestore());
  }
}
