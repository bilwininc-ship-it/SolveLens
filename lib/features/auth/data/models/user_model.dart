class UserModel {
  final String uid;
  final String email;
  final bool isPremium;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.isPremium = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}