// Chat Message Model for Super Chat feature
import 'dart:io';
import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;
  final String? audioUrl; // Firebase Storage URL for audio
  final bool hasImage;
  final bool hasAudio;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.audioUrl,
    this.hasImage = false,
    this.hasAudio = false,
  });

  /// Creates a user text message
  factory ChatMessageModel.userText({
    required String id,
    required String text,
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      hasImage: false,
      hasAudio: false,
    );
  }

  /// Creates a user image message
  factory ChatMessageModel.userImage({
    required String id,
    required File imageFile,
    String text = '',
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageFile: imageFile,
      hasImage: true,
      hasAudio: false,
    );
  }

  /// Creates a user voice message (transcribed)
  factory ChatMessageModel.userVoice({
    required String id,
    required String transcribedText,
  }) {
    return ChatMessageModel(
      id: id,
      text: transcribedText,
      isUser: true,
      timestamp: DateTime.now(),
      hasImage: false,
      hasAudio: false,
    );
  }

  /// Creates a professor text response
  factory ChatMessageModel.professorText({
    required String id,
    required String text,
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      hasImage: false,
      hasAudio: false,
    );
  }

  /// Creates a professor audio response
  factory ChatMessageModel.professorAudio({
    required String id,
    required String text,
    required String audioUrl,
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      audioUrl: audioUrl,
      hasImage: false,
      hasAudio: true,
    );
  }

  /// Creates a copy with updated fields
  ChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    File? imageFile,
    String? audioUrl,
    bool? hasImage,
    bool? hasAudio,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageFile: imageFile ?? this.imageFile,
      audioUrl: audioUrl ?? this.audioUrl,
      hasImage: hasImage ?? this.hasImage,
      hasAudio: hasAudio ?? this.hasAudio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        isUser,
        timestamp,
        imageFile,
        audioUrl,
        hasImage,
        hasAudio,
      ];
}
