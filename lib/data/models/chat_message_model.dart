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
  final File? pdfFile;
  final bool hasPDF;
  final String? pdfFileName;
  final String? pdfFileSize;

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
      ];
}
