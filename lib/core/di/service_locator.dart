// Service locator for dependency injection
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/ai/ai_service.dart';
import '../../services/payment/payment_service.dart';
import '../../services/user/user_service.dart';
import '../../services/device/device_service.dart';
import '../../services/config/remote_config_service.dart';
import '../../services/database/realtime_database_service.dart';
import '../../services/notes/notes_service.dart';
import '../../services/voice/voice_service.dart';
import '../../services/quota/quota_service.dart';
import '../../services/conversation/conversation_service.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/usecases/analyze_question_usecase.dart';
import '../../domain/usecases/get_question_history_usecase.dart';
import '../../presentation/providers/solution_provider.dart';
import '../constants/app_constants.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies
Future<void> setupServiceLocator() async {
  try {
    // External dependencies
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    // Firebase Realtime Database
    getIt.registerLazySingleton<FirebaseDatabase>(
      () => FirebaseDatabase.instance,
    );

    // Remote Config Service - with error handling for web
    RemoteConfigService? remoteConfigService;
    try {
      remoteConfigService = RemoteConfigService();
      await remoteConfigService.initialize();
      getIt.registerLazySingleton<RemoteConfigService>(
        () => remoteConfigService!,
      );
      print('✅ Remote Config initialized successfully');
    } catch (e) {
      print('⚠️ Remote Config initialization failed (non-critical): $e');
      // Register a dummy service for web compatibility
      getIt.registerLazySingleton<RemoteConfigService>(
        () => RemoteConfigService(),
      );
    }

    // Payment Service - only for mobile platforms
    if (!kIsWeb) {
      try {
        final paymentService = PaymentService();
        await paymentService.initialize();
        getIt.registerLazySingleton<PaymentService>(
          () => paymentService,
        );
        print('✅ Payment Service initialized successfully');
      } catch (e) {
        print('⚠️ Payment Service initialization failed: $e');
        // Register a dummy payment service for web
        getIt.registerLazySingleton<PaymentService>(
          () => PaymentService(),
        );
      }
    } else {
      // Web platform - register dummy payment service
      getIt.registerLazySingleton<PaymentService>(
        () => PaymentService(),
      );
      print('ℹ️ Payment Service skipped for web platform');
    }

  // Device Service (for anti-fraud)
  getIt.registerLazySingleton<DeviceService>(
    () => DeviceService(getIt<FirebaseFirestore>()),
  );

  // User Service (with Device Service for anti-fraud)
  getIt.registerLazySingleton<UserService>(
    () => UserService(
      getIt<FirebaseFirestore>(),
      getIt<DeviceService>(),
    ),
  );

  // AI Service (with Remote Config key, Gemini 2.5 Flash, and Firebase Database)
  // API key is fetched from Firebase Remote Config for security
  String geminiApiKey = '';
  try {
    geminiApiKey = getIt<RemoteConfigService>().getGeminiApiKey('');
  } catch (e) {
    print('⚠️ Could not fetch Gemini API key from Remote Config: $e');
  }
  
  getIt.registerLazySingleton<AIService>(
    () => AIService(
      geminiApiKey,
      getIt<FirebaseDatabase>(),
    ),
  );

  // Realtime Database Service
  getIt.registerLazySingleton<RealtimeDatabaseService>(
    () => RealtimeDatabaseService(getIt<FirebaseDatabase>()),
  );

  // Notes Service
  getIt.registerLazySingleton<NotesService>(
    () => NotesService(getIt<FirebaseFirestore>()),
  );

  // Voice Service (with Remote Config for TTS settings)
  getIt.registerLazySingleton<VoiceService>(
    () => VoiceService(getIt<RemoteConfigService>()),
  );

  // Quota Service (for tracking text and voice usage)
  getIt.registerLazySingleton<QuotaService>(
    () => QuotaService(
      getIt<FirebaseFirestore>(),
      getIt<RemoteConfigService>(),
    ),
  );

  // Conversation Service (for managing chat sessions)
  getIt.registerLazySingleton<ConversationService>(
    () => ConversationService(getIt<FirebaseFirestore>()),
  );

  // Repositories
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(
      aiService: getIt<AIService>(),
      databaseService: getIt<RealtimeDatabaseService>(),
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
  
  print('✅ Service Locator setup completed successfully');
  } catch (e) {
    print('❌ Service Locator setup error: $e');
    print('Stack trace: ${StackTrace.current}');
    rethrow;
  }
}
