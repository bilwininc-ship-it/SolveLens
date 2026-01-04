// Repository interface for question analysis (Domain Layer)
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/question.dart';
import 'dart:io';

abstract class QuestionRepository {
  /// Analyzes an image containing a homework question
  /// Returns Either a Failure or a Question entity
  Future<Either<Failure, Question>> analyzeQuestion({
    required File imageFile,
    required String userId,
  });
  
  /// Retrieves question history for a user
  Future<Either<Failure, List<Question>>> getQuestionHistory({
    required String userId,
    int limit = 20,
  });
  
  /// Saves a question to the user's history
  Future<Either<Failure, void>> saveQuestion({
    required Question question,
  });
}
