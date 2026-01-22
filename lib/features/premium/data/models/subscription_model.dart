class SubscriptionModel {
  final String id;
  final String userId;
  final bool isActive;
  final DateTime expiresAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.expiresAt,
  });
}