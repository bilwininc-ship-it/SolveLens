// Homework question domain entity
import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String question;
  final String answer;
  final DateTime createdAt;
  final String subject; // Math, Physics, Chemistry, etc.
  
  const Question({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.subject,
  });
  
  @override
  List<Object> get props => [id, userId, imageUrl, question, answer, createdAt, subject];
}
