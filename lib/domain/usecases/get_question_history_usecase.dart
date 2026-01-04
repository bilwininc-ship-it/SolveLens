// Use case for retrieving question history (Domain Layer)
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetQuestionHistoryUseCase {
  final QuestionRepository repository;

  GetQuestionHistoryUseCase(this.repository);

  Future<Either<Failure, List<Question>>> call({
    required String userId,
    int limit = 20,
  }) async {
    return await repository.getQuestionHistory(
      userId: userId,
      limit: limit,
    );
  }
}
