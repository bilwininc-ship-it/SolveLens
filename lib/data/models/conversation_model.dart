// Conversation Model for managing multiple chat sessions
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final ChatMode mode; // Chat mode for this conversation

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.mode = ChatMode.textToText,
  });

  /// Creates from Firestore document
  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'New Conversation',
      lastMessage: data['lastMessage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      messageCount: data['messageCount'] ?? 0,
      mode: ChatMode.values.firstWhere(
        (e) => e.toString() == data['mode'],
        orElse: () => ChatMode.textToText,
      ),
    );
  }

  /// Converts to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'lastMessage': lastMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messageCount': messageCount,
      'mode': mode.toString(),
    };
  }

  /// Creates a copy with updated fields
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    ChatMode? mode,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        lastMessage,
        createdAt,
        updatedAt,
        messageCount,
        mode,
      ];
}

/// Chat modes available in the app
enum ChatMode {
  textToText,      // Default: Text input, text response
  voiceToText,     // Voice input, text response
  textToVoice,     // Text input, voice response
  liveVoiceChat,   // Live voice conversation
}

extension ChatModeExtension on ChatMode {
  String get displayName {
    switch (this) {
      case ChatMode.textToText:
        return 'Metin → Metin';
      case ChatMode.voiceToText:
        return 'Ses → Metin';
      case ChatMode.textToVoice:
        return 'Metin → Ses';
      case ChatMode.liveVoiceChat:
        return 'Canlı Sesli Sohbet';
    }
  }

  String get icon {
    switch (this) {
      case ChatMode.textToText:
        return '💬';
      case ChatMode.voiceToText:
        return '🎤';
      case ChatMode.textToVoice:
        return '🔊';
      case ChatMode.liveVoiceChat:
        return '📞';
    }
  }

  String get description {
    switch (this) {
      case ChatMode.textToText:
        return 'Metin yaz, metin al';
      case ChatMode.voiceToText:
        return 'Konuş, metin al';
      case ChatMode.textToVoice:
        return 'Yaz, sesli yanıt al';
      case ChatMode.liveVoiceChat:
        return 'Konuş ve sesli yanıt al';
    }
  }
}
