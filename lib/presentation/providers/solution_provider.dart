// Provider for managing solution analysis with security checks
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/usecases/analyze_question_usecase.dart';
import '../../domain/entities/question.dart';
import '../../services/payment/payment_service.dart';
import '../../services/user/user_service.dart';
import 'solution_state.dart';

class SolutionProvider extends ChangeNotifier {
  final AnalyzeQuestionUseCase analyzeQuestionUseCase;
  final PaymentService paymentService;
  final UserService userService;
  
  SolutionState _state = const SolutionIdle();
  SolutionState get state => _state;

  Question? _currentQuestion;
  Question? get currentQuestion => _currentQuestion;

  SubscriptionStatus? _subscriptionStatus;
  SubscriptionStatus? get subscriptionStatus => _subscriptionStatus;

  SolutionProvider({
    required this.analyzeQuestionUseCase,
    required this.paymentService,
    required this.userService,
  });

  /// Initializes subscription status
  Future<void> initialize() async {
    _subscriptionStatus = await paymentService.checkSubscriptionStatus();
    notifyListeners();
  }

  /// Analyzes a question with security checks
  Future<void> analyzeQuestion({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Check subscription status first
      if (_subscriptionStatus == null) {
        await initialize();
      }

      // Check daily limit
      final hasExceeded = await userService.hasExceededDailyLimit(
        userId,
        _subscriptionStatus!.dailyLimit,
      );

      if (hasExceeded) {
        _setState(SolutionError(
          message: 'Daily limit reached. Upgrade to  for more questions!',
          isRateLimitError: true,
        ));
        return;
      }

      // Set scanning state
      _setState(const SolutionScanning());
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Set analyzing state
      _setState(const SolutionAnalyzing(progress: 0.0));
      _simulateProgress();

      // Execute use case
      final result = await analyzeQuestionUseCase(
        imageFile: imageFile,
        userId: userId,
      );

      result.fold(
        (failure) {
          if (failure.message.contains('limit') || 
              failure.message.contains('Premium')) {
            _setState(SolutionError(
              message: failure.message,
              isRateLimitError: true,
            ));
          } else if (failure.message.contains('unclear') || 
                     failure.message.contains('detect')) {
            _setState(SolutionError(
              message: failure.message,
              isBlurryImage: true,
            ));
          } else {
            _setState(SolutionError(message: failure.message));
          }
        },
        (question) async {
          // Success - increment counter
          await userService.incrementQuestionCounter(userId);
          _currentQuestion = question;
          _setState(SolutionSuccess(question));
        },
      );
      
    } catch (e) {
      _setState(SolutionError(message: 'An error occurred: $e'));
    }
  }

  /// Gets the next tier for upgrade messaging
  String _getNextTier() {
    if (_subscriptionStatus == null) return 'Premium';
    
    switch (_subscriptionStatus!.tier) {
      case SubscriptionTier.free:
        return 'Basic (\$4.99/mo)';
      case SubscriptionTier.basic:
        return 'Pro (\$9.99/mo)';
      case SubscriptionTier.pro:
        return 'Elite (\$19.99/mo)';
      case SubscriptionTier.elite:
        return 'Elite'; // Already at max
    }
  }

  /// Simulates analysis progress
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_state is SolutionAnalyzing) {
        _setState(const SolutionAnalyzing(progress: 0.3));
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_state is SolutionAnalyzing) {
        _setState(const SolutionAnalyzing(progress: 0.6));
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_state is SolutionAnalyzing) {
        _setState(const SolutionAnalyzing(progress: 0.9));
      }
    });
  }

  /// Refreshes subscription status
  Future<void> refreshSubscription() async {
    _subscriptionStatus = await paymentService.checkSubscriptionStatus();
    notifyListeners();
  }

  /// Resets the state to idle
  void reset() {
    _setState(const SolutionIdle());
    _currentQuestion = null;
  }

  void _setState(SolutionState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _currentQuestion = null;
    _subscriptionStatus = null;
    super.dispose();
  }
}
