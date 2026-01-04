// Use case for analyzing a question image (Domain Layer)
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';
import 'dart:io';

class AnalyzeQuestionUseCase {
  final QuestionRepository repository;

  AnalyzeQuestionUseCase(this.repository);

  /// Executes the use case to analyze a question
  /// Returns Either a Failure or a Question entity
  Future<Either<Failure, Question>> call({
    required File imageFile,
    required String userId,
  }) async {
    // Validate image file
    if (!await imageFile.exists()) {
      return const Left(CacheFailure('Image file does not exist'));
    }

    // Check file size (max 4MB for optimal performance)
    final fileSize = await imageFile.length();
    if (fileSize > 4 * 1024 * 1024) {
      return const Left(CacheFailure('Image file too large. Please use a smaller image.'));
    }

    // Call repository
    return await repository.analyzeQuestion(
      imageFile: imageFile,
      userId: userId,
    );
  }
}
