// User model for data layer
import '../../domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends User {
  final DateTime? lastQuestionDate;

  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.subscriptionType,
    super.subscriptionExpiryDate,
    required super.questionsUsedToday,
    this.lastQuestionDate,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      subscriptionType: data['subscriptionType'] ?? 'free',
      subscriptionExpiryDate: data['subscriptionExpiryDate'] != null
          ? (data['subscriptionExpiryDate'] as Timestamp).toDate()
          : null,
      questionsUsedToday: data['questionsUsedToday'] ?? 0,
      lastQuestionDate: data['lastQuestionDate'] != null
          ? (data['lastQuestionDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'subscriptionType': subscriptionType,
      'subscriptionExpiryDate': subscriptionExpiryDate != null
          ? Timestamp.fromDate(subscriptionExpiryDate!)
          : null,
      'questionsUsedToday': questionsUsedToday,
      'lastQuestionDate': lastQuestionDate != null
          ? Timestamp.fromDate(lastQuestionDate!)
          : null,
    };
  }
}
