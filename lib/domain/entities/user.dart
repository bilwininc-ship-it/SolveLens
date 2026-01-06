// User domain entity
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String subscriptionType; // 'free', 'basic', 'pro', 'elite'
  final DateTime? subscriptionExpiryDate;
  final int questionsUsedToday;
  final DateTime? lastQuestionDate; // Added field
  
  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.subscriptionType,
    this.subscriptionExpiryDate,
    required this.questionsUsedToday,
    this.lastQuestionDate,
  });
  
  @override
  List<Object?> get props => [
    id, 
    email, 
    displayName, 
    subscriptionType, 
    subscriptionExpiryDate,
    questionsUsedToday,
    lastQuestionDate,
  ];
}
