// Question model for data layer (extends domain entity)
import '../../domain/entities/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.userId,
    required super.imageUrl,
    required super.question,
    required super.answer,
    required super.createdAt,
    required super.subject,
  });

  /// Creates a QuestionModel from a Question entity
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      userId: question.userId,
      imageUrl: question.imageUrl,
      question: question.question,
      answer: question.answer,
      createdAt: question.createdAt,
      subject: question.subject,
    );
  }

  /// Creates a QuestionModel from Firestore document
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      subject: data['subject'] ?? 'General',
    );
  }

  /// Creates a QuestionModel from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      subject: json['subject'] ?? 'General',
    );
  }

  /// Converts QuestionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
      'subject': subject,
    };
  }

  /// Converts QuestionModel to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'question': question,
      'answer': answer,
      'createdAt': Timestamp.fromDate(createdAt),
      'subject': subject,
    };
  }
}
