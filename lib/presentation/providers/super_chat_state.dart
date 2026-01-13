// States for Super Chat feature
import 'package:equatable/equatable.dart';
import '../../data/models/chat_message_model.dart';

abstract class SuperChatState extends Equatable {
  const SuperChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no messages yet
class SuperChatInitial extends SuperChatState {
  const SuperChatInitial();
}

/// Loaded state with messages
class SuperChatLoaded extends SuperChatState {
  final List<ChatMessageModel> messages;

  const SuperChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// Processing state - AI is generating response
class SuperChatProcessing extends SuperChatState {
  final List<ChatMessageModel> messages;
  final String processingMessage;

  const SuperChatProcessing({
    required this.messages,
    this.processingMessage = 'Professor is thinking...',
  });

  @override
  List<Object?> get props => [messages, processingMessage];
}

/// Error state
class SuperChatError extends SuperChatState {
  final List<ChatMessageModel> messages;
  final String errorMessage;

  const SuperChatError({
    required this.messages,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [messages, errorMessage];
}

/// Quota exceeded state
class SuperChatQuotaExceeded extends SuperChatState {
  final List<ChatMessageModel> messages;
  final String quotaType; // 'text', 'voice', 'image'

  const SuperChatQuotaExceeded({
    required this.messages,
    required this.quotaType,
  });

  @override
  List<Object?> get props => [messages, quotaType];
}
