// Saved Note Model for Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedNoteModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String solutionText;
  final String question;
  final String subject;
  final DateTime createdAt;

  const SavedNoteModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.solutionText,
    required this.question,
    required this.subject,
    required this.createdAt,
  });

  /// Creates from Firestore document
  factory SavedNoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedNoteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      solutionText: data['solutionText'] ?? '',
      question: data['question'] ?? '',
      subject: data['subject'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'solutionText': solutionText,
      'question': question,
      'subject': subject,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates from JSON
  factory SavedNoteModel.fromJson(Map<String, dynamic> json) {
    return SavedNoteModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      solutionText: json['solutionText'] ?? '',
      question: json['question'] ?? '',
      subject: json['subject'] ?? 'General',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'solutionText': solutionText,
      'question': question,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
