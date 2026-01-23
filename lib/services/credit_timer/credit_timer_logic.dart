import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';

/// Credit Timer Logic - Daily Rewarded Ad Cooldown Management
/// 
/// Manages 24-hour cooldown between rewarded ad claims.
/// Ensures users can only earn +1 credit per day from ads.
/// 
/// Key Features:
/// - 24-hour cooldown enforcement
/// - Real-time countdown calculation
/// - Firestore timestamp management
/// - Efficient performance (no CPU stress)
class CreditTimerLogic {
  static const Duration cooldownDuration = Duration(hours: 24);

  /// Check if user can claim rewarded ad credit
  /// 
  /// Returns true if:
  /// - User has never claimed before (last_ad_claim_at is null)
  /// - 24 hours have passed since last claim
  /// 
  /// Parameters:
  /// - [lastClaimAt]: Firestore Timestamp of last ad claim (nullable)
  static bool canClaimCredit(Timestamp? lastClaimAt) {
    if (lastClaimAt == null) {
      // User has never claimed - allow first claim
      return true;
    }

    final lastClaimDateTime = lastClaimAt.toDate();
    final now = DateTime.now();
    final timeSinceLastClaim = now.difference(lastClaimDateTime);

    final canClaim = timeSinceLastClaim >= cooldownDuration;
    
    Logger.log(
      'Can claim credit: $canClaim (Time since last: ${timeSinceLastClaim.inHours}h)',
      tag: 'CreditTimer',
    );

    return canClaim;
  }

  /// Calculate remaining time until next claim is available
  /// 
  /// Returns Duration representing time left in cooldown.
  /// Returns Duration.zero if cooldown has expired.
  /// 
  /// Parameters:
  /// - [lastClaimAt]: Firestore Timestamp of last ad claim
  static Duration getRemainingTime(Timestamp? lastClaimAt) {
    if (lastClaimAt == null) {
      return Duration.zero;
    }

    final lastClaimDateTime = lastClaimAt.toDate();
    final now = DateTime.now();
    final nextClaimTime = lastClaimDateTime.add(cooldownDuration);
    
    if (now.isAfter(nextClaimTime)) {
      return Duration.zero;
    }

    final remaining = nextClaimTime.difference(now);
    
    Logger.log(
      'Remaining time: ${remaining.inHours}h ${remaining.inMinutes % 60}m',
      tag: 'CreditTimer',
    );

    return remaining;
  }

  /// Format remaining time for UI display
  /// 
  /// Examples:
  /// - "23h 45m" (23 hours, 45 minutes)
  /// - "5h 30m" (5 hours, 30 minutes)
  /// - "0h 15m" (15 minutes)
  /// 
  /// Parameters:
  /// - [duration]: Duration to format
  static String formatRemainingTime(Duration duration) {
    if (duration == Duration.zero) {
      return 'Available now';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  /// Update user's last ad claim timestamp in Firestore
  /// 
  /// Sets last_ad_claim_at to current server timestamp.
  /// This starts the 24-hour cooldown period.
  /// 
  /// Parameters:
  /// - [userId]: User's Firebase UID
  static Future<void> updateLastClaimTimestamp(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'last_ad_claim_at': FieldValue.serverTimestamp(),
      });

      Logger.log(
        'Updated last_ad_claim_at for user: $userId',
        tag: 'CreditTimer',
      );
    } catch (e) {
      Logger.error(
        'Failed to update last_ad_claim_at',
        error: e,
        tag: 'CreditTimer',
      );
      rethrow;
    }
  }

  /// Increment user credits by specified amount
  /// 
  /// Uses Firestore FieldValue.increment for atomic operation.
  /// Prevents race conditions when multiple operations occur.
  /// 
  /// Parameters:
  /// - [userId]: User's Firebase UID
  /// - [amount]: Credits to add (default: 1)
  static Future<void> incrementUserCredits(
    String userId, {
    int amount = 1,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'credits': FieldValue.increment(amount),
      });

      Logger.log(
        'Incremented credits by $amount for user: $userId',
        tag: 'CreditTimer',
      );
    } catch (e) {
      Logger.error(
        'Failed to increment credits',
        error: e,
        tag: 'CreditTimer',
      );
      rethrow;
    }
  }

  /// Complete rewarded ad claim process
  /// 
  /// Atomic operation that:
  /// 1. Increments user credits by +1
  /// 2. Updates last_ad_claim_at timestamp
  /// 3. Starts new 24-hour cooldown
  /// 
  /// Parameters:
  /// - [userId]: User's Firebase UID
  static Future<void> completeAdClaim(String userId) async {
    try {
      // Use batch write for atomic operation
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      batch.update(userRef, {
        'credits': FieldValue.increment(1),
        'last_ad_claim_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      Logger.log(
        'Completed ad claim for user: $userId (+1 credit)',
        tag: 'CreditTimer',
      );
    } catch (e) {
      Logger.error(
        'Failed to complete ad claim',
        error: e,
        tag: 'CreditTimer',
      );
      rethrow;
    }
  }

  /// Get next claim availability time as DateTime
  /// 
  /// Returns null if claim is available now.
  /// Returns DateTime of when next claim will be available.
  /// 
  /// Parameters:
  /// - [lastClaimAt]: Firestore Timestamp of last ad claim
  static DateTime? getNextClaimTime(Timestamp? lastClaimAt) {
    if (lastClaimAt == null) {
      return null;
    }

    final lastClaimDateTime = lastClaimAt.toDate();
    final nextClaimTime = lastClaimDateTime.add(cooldownDuration);
    final now = DateTime.now();

    if (now.isAfter(nextClaimTime)) {
      return null;
    }

    return nextClaimTime;
  }
}
