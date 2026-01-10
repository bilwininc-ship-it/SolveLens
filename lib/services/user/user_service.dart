// User service for managing daily limits and subscription data
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';
import '../device/device_service.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final DeviceService _deviceService;

  UserService(this._firestore, this._deviceService);

  /// Gets user document from Firestore
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) return null;
      
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw UserServiceException('Failed to get user: $e');
    }
  }

  /// Checks if user OR device has exceeded daily limit (Anti-fraud: Both must pass)
  Future<bool> hasExceededDailyLimit(String userId, int dailyLimit) async {
    try {
      // Check user-based limit
      final user = await getUser(userId);
      bool userExceeded = false;
      
      if (user != null) {
        // Check if it's a new day (reset counter)
        final lastUpdate = user.lastQuestionDate ?? DateTime(2000);
        final today = DateTime.now();
        
        if (!_isSameDay(lastUpdate, today)) {
          // New day, reset counter
          await _resetDailyCounter(userId);
        } else {
          // Check against limit
          userExceeded = user.questionsUsedToday >= dailyLimit;
        }
      }

      // Check device-based limit (Anti-fraud)
      final deviceId = await _deviceService.getDeviceId();
      final deviceExceeded = await _deviceService.hasDeviceExceededDailyLimit(
        deviceId,
        dailyLimit,
      );

      // If EITHER user OR device exceeded limit, return true (trigger paywall)
      return userExceeded || deviceExceeded;
      
    } catch (e) {
      throw UserServiceException('Failed to check daily limit: $e');
    }
  }

  /// Increments user's daily question counter (and device counter for anti-fraud)
  Future<void> incrementQuestionCounter(String userId) async {
    try {
      // Increment user counter
      final userRef = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        
        if (!snapshot.exists) {
          // Create new user document
          transaction.set(userRef, {
            'userId': userId,
            'questionsUsedToday': 1,
            'lastQuestionDate': FieldValue.serverTimestamp(),
            'subscriptionType': 'free',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = snapshot.data()!;
          final lastUpdate = (data['lastQuestionDate'] as Timestamp?)?.toDate();
          final today = DateTime.now();
          
          if (lastUpdate == null || !_isSameDay(lastUpdate, today)) {
            // New day, reset counter
            transaction.update(userRef, {
              'questionsUsedToday': 1,
              'lastQuestionDate': FieldValue.serverTimestamp(),
            });
          } else {
            // Same day, increment counter
            transaction.update(userRef, {
              'questionsUsedToday': FieldValue.increment(1),
              'lastQuestionDate': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      // Also increment device counter (Anti-fraud)
      final deviceId = await _deviceService.getDeviceId();
      await _deviceService.incrementDeviceQuestionCounter(deviceId);
    } catch (e) {
      throw UserServiceException('Failed to increment counter: $e');
    }
  }

  /// Resets daily counter (called automatically on new day)
  Future<void> _resetDailyCounter(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'questionsUsedToday': 0,
      'lastQuestionDate': FieldValue.serverTimestamp(),
    });
  }

  /// Checks if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Syncs subscription status from RevenueCat to Firestore
  /// This should be called after subscription changes
  Future<void> syncSubscriptionStatus(
    String userId,
    String subscriptionType,
    int dailyLimit,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'subscriptionType': subscriptionType,
        'dailyLimit': dailyLimit,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw UserServiceException('Failed to sync subscription: $e');
    }
  }
}

class UserServiceException implements Exception {
  final String message;
  UserServiceException(this.message);
  
  @override
  String toString() => message;
}
