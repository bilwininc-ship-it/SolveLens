// Service locator for dependency injection
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai/ai_service.dart';
import '../services/payment/payment_service.dart';
import '../services/user/user_service.dart';
import '../services/config/remote_config_service.dart';
import '../data/repositories/question_repository_impl.dart';
import '../domain/repositories/question_repository.dart';
import '../domain/usecases/analyze_question_usecase.dart';
import '../domain/usecases/get_question_history_usecase.dart';
import '../presentation/providers/solution_provider.dart';
import '../core/constants/app_constants.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies
Future<void> setupServiceLocator() async {
  // External dependencies
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Remote Config Service
  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();
  getIt.registerLazySingleton<RemoteConfigService>(
    () => remoteConfigService,
  );

  // Payment Service
  final paymentService = PaymentService();
  await paymentService.initialize();
  getIt.registerLazySingleton<PaymentService>(
    () => paymentService,
  );

  // User Service
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<FirebaseFirestore>()),
  );

  // AI Service (with Remote Config key)
  getIt.registerLazySingleton<AIService>(
    () => AIService(
      remoteConfigService.getGeminiApiKey(AppConstants.geminiApiKey),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(
      aiService: getIt<AIService>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<AnalyzeQuestionUseCase>(
    () => AnalyzeQuestionUseCase(getIt<QuestionRepository>()),
  );

  getIt.registerLazySingleton<GetQuestionHistoryUseCase>(
    () => GetQuestionHistoryUseCase(getIt<QuestionRepository>()),
  );

  // Providers
  getIt.registerFactory<SolutionProvider>(
    () => SolutionProvider(
      analyzeQuestionUseCase: getIt<AnalyzeQuestionUseCase>(),
      paymentService: getIt<PaymentService>(),
      userService: getIt<UserService>(),
    ),
  );
}
