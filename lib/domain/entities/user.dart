// User domain entity
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String subscriptionType; // 'free', 'basic', 'pro', 'elite'
  final DateTime? subscriptionExpiryDate;
  final int questionsUsedToday;
  
  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.subscriptionType,
    this.subscriptionExpiryDate,
    required this.questionsUsedToday,
  });
  
  @override
  List<Object?> get props => [
    id, 
    email, 
    displayName, 
    subscriptionType, 
    subscriptionExpiryDate,
    questionsUsedToday
  ];
}
