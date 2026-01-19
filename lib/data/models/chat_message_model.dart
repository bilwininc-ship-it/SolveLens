// Chat Message Model for Super Chat feature
import 'dart:io';
import 'package:equatable/equatable.dart';
import './conversation_model.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;
  final String? audioUrl; // Firebase Storage URL for audio
  final bool hasImage;
  final bool hasAudio;
  final File? pdfFile;
  final bool hasPDF;
  final String? pdfFileName;
  final String? pdfFileSize;
  final ChatMode? mode; // Chat mode for this message
  final bool isVoice; // If message was sent via voice
  final String? imageUrl; // URL or path to image
  final String? pdfUrl; // URL or path to PDF

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.audioUrl,
    this.hasImage = false,
    this.hasAudio = false,
    this.pdfFile,
    this.hasPDF = false,
    this.pdfFileName,
    this.pdfFileSize,
    this.mode,
    this.isVoice = false,
    this.imageUrl,
    this.pdfUrl,
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
      hasPDF: false,
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
      hasPDF: false,
    );
  }

  /// Creates a user PDF message
  factory ChatMessageModel.userPDF({
    required String id,
    required File pdfFile,
    required String pdfFileName,
    required String pdfFileSize,
    String text = '',
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      pdfFile: pdfFile,
      pdfFileName: pdfFileName,
      pdfFileSize: pdfFileSize,
      hasImage: false,
      hasAudio: false,
      hasPDF: true,
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
      hasPDF: false,
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
      hasPDF: false,
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
      hasPDF: false,
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
    File? pdfFile,
    bool? hasPDF,
    String? pdfFileName,
    String? pdfFileSize,
    ChatMode? mode,
    bool? isVoice,
    String? imageUrl,
    String? pdfUrl,
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
      pdfFile: pdfFile ?? this.pdfFile,
      hasPDF: hasPDF ?? this.hasPDF,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      pdfFileSize: pdfFileSize ?? this.pdfFileSize,
      mode: mode ?? this.mode,
      isVoice: isVoice ?? this.isVoice,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
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
        pdfFile,
        hasPDF,
        pdfFileName,
        pdfFileSize,
        mode,
        isVoice,
        imageUrl,
        pdfUrl,
      ];
}
