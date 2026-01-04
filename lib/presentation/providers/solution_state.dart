// States for solution analysis process
import 'package:equatable/equatable.dart';
import '../../domain/entities/question.dart';

abstract class SolutionState extends Equatable {
  const SolutionState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state
class SolutionIdle extends SolutionState {
  const SolutionIdle();
}

/// Scanning image state
class SolutionScanning extends SolutionState {
  const SolutionScanning();
}

/// Analyzing with AI state
class SolutionAnalyzing extends SolutionState {
  final double progress;

  const SolutionAnalyzing({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

/// Success state with solution
class SolutionSuccess extends SolutionState {
  final Question question;

  const SolutionSuccess(this.question);

  @override
  List<Object?> get props => [question];
}

/// Error state
class SolutionError extends SolutionState {
  final String message;
  final bool isRateLimitError;
  final bool isBlurryImage;

  const SolutionError({
    required this.message,
    this.isRateLimitError = false,
    this.isBlurryImage = false,
  });

  @override
  List<Object?> get props => [message, isRateLimitError, isBlurryImage];
}
