// Quota Service for tracking text messages and voice minutes usage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/remote_config_service.dart';

class QuotaService {
  final FirebaseFirestore _firestore;
  final RemoteConfigService _remoteConfig;
  
  QuotaService(this._firestore, this._remoteConfig);

  /// Gets current quota usage for a user
  Future<QuotaUsage> getQuotaUsage(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final monthStart = _getMonthStart(now);

      // Fetch user quota document
      final docRef = _firestore.collection('user_quotas').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Initialize quota document for new user
        await _initializeQuota(userId, weekStart, monthStart);
        return QuotaUsage(
          textMessagesUsed: 0,
          voiceMinutesUsed: 0,
          textMessagesLimit: _getTextLimit(),
          voiceMinutesLimit: _getVoiceLimit(),
          weekStart: weekStart,
          monthStart: monthStart,
        );
      }

      final data = doc.data()!;
      final lastWeekStart = (data['weekStart'] as Timestamp?)?.toDate();
      final lastMonthStart = (data['monthStart'] as Timestamp?)?.toDate();

      // Check if we need to reset weekly/monthly counters
      if (lastWeekStart == null || weekStart.isAfter(lastWeekStart)) {
        await _resetWeeklyQuota(userId, weekStart);
        return QuotaUsage(
          textMessagesUsed: 0,
          voiceMinutesUsed: 0,
          textMessagesLimit: _getTextLimit(),
          voiceMinutesLimit: _getVoiceLimit(),
          weekStart: weekStart,
          monthStart: monthStart,
        );
      }

      if (lastMonthStart == null || monthStart.isAfter(lastMonthStart)) {
        await _resetMonthlyQuota(userId, monthStart);
        return QuotaUsage(
          textMessagesUsed: 0,
          voiceMinutesUsed: 0,
          textMessagesLimit: _getTextLimit(),
          voiceMinutesLimit: _getVoiceLimit(),
          weekStart: weekStart,
          monthStart: monthStart,
        );
      }

      return QuotaUsage(
        textMessagesUsed: data['textMessagesUsed'] ?? 0,
        voiceMinutesUsed: (data['voiceMinutesUsed'] ?? 0).toDouble(),
        textMessagesLimit: _getTextLimit(),
        voiceMinutesLimit: _getVoiceLimit(),
        weekStart: weekStart,
        monthStart: monthStart,
      );
    } catch (e) {
      debugPrint('Error fetching quota usage: $e');
      rethrow;
    }
  }

  /// Increments text message count
  Future<bool> incrementTextMessage(String userId) async {
    try {
      final usage = await getQuotaUsage(userId);
      
      if (usage.textMessagesUsed >= usage.textMessagesLimit) {
        return false; // Quota exceeded
      }

      await _firestore.collection('user_quotas').doc(userId).update({
        'textMessagesUsed': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error incrementing text message: $e');
      return false;
    }
  }

  /// Increments voice minutes used
  Future<bool> incrementVoiceMinutes(String userId, double minutes) async {
    try {
      final usage = await getQuotaUsage(userId);
      
      if (usage.voiceMinutesUsed + minutes > usage.voiceMinutesLimit) {
        return false; // Quota exceeded
      }

      await _firestore.collection('user_quotas').doc(userId).update({
        'voiceMinutesUsed': FieldValue.increment(minutes),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error incrementing voice minutes: $e');
      return false;
    }
  }

  /// Streams quota updates in real-time
  Stream<QuotaUsage> streamQuotaUsage(String userId) {
    return _firestore
        .collection('user_quotas')
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) {
        final now = DateTime.now();
        return QuotaUsage(
          textMessagesUsed: 0,
          voiceMinutesUsed: 0,
          textMessagesLimit: _getTextLimit(),
          voiceMinutesLimit: _getVoiceLimit(),
          weekStart: _getWeekStart(now),
          monthStart: _getMonthStart(now),
        );
      }

      final data = snapshot.data()!;
      final now = DateTime.now();
      
      return QuotaUsage(
        textMessagesUsed: data['textMessagesUsed'] ?? 0,
        voiceMinutesUsed: (data['voiceMinutesUsed'] ?? 0).toDouble(),
        textMessagesLimit: _getTextLimit(),
        voiceMinutesLimit: _getVoiceLimit(),
        weekStart: _getWeekStart(now),
        monthStart: _getMonthStart(now),
      );
    });
  }

  /// Initializes quota document for a new user
  Future<void> _initializeQuota(
    String userId,
    DateTime weekStart,
    DateTime monthStart,
  ) async {
    await _firestore.collection('user_quotas').doc(userId).set({
      'textMessagesUsed': 0,
      'voiceMinutesUsed': 0,
      'weekStart': Timestamp.fromDate(weekStart),
      'monthStart': Timestamp.fromDate(monthStart),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Resets weekly quota
  Future<void> _resetWeeklyQuota(String userId, DateTime weekStart) async {
    await _firestore.collection('user_quotas').doc(userId).update({
      'textMessagesUsed': 0,
      'weekStart': Timestamp.fromDate(weekStart),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Resets monthly quota
  Future<void> _resetMonthlyQuota(String userId, DateTime monthStart) async {
    await _firestore.collection('user_quotas').doc(userId).update({
      'voiceMinutesUsed': 0,
      'monthStart': Timestamp.fromDate(monthStart),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Gets the start of the current week (Monday)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Gets the start of the current month
  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Gets text message limit from Remote Config
  int _getTextLimit() {
    try {
      final limit = _remoteConfig.getMaxFreeQuestions();
      return limit > 0 ? limit : 150; // Default weekly limit
    } catch (e) {
      return 150;
    }
  }

  /// Gets voice minutes limit from Remote Config
  double _getVoiceLimit() {
    try {
      final limit = _remoteConfig.getMaxVoiceMinutes();
      return limit > 0 ? limit : 15.0; // Default monthly limit
    } catch (e) {
      return 15.0;
    }
  }
}

/// Model for quota usage
class QuotaUsage {
  final int textMessagesUsed;
  final double voiceMinutesUsed;
  final int textMessagesLimit;
  final double voiceMinutesLimit;
  final DateTime weekStart;
  final DateTime monthStart;

  QuotaUsage({
    required this.textMessagesUsed,
    required this.voiceMinutesUsed,
    required this.textMessagesLimit,
    required this.voiceMinutesLimit,
    required this.weekStart,
    required this.monthStart,
  });

  double get textProgress => textMessagesUsed / textMessagesLimit;
  double get voiceProgress => voiceMinutesUsed / voiceMinutesLimit;

  bool get hasTextQuota => textMessagesUsed < textMessagesLimit;
  bool get hasVoiceQuota => voiceMinutesUsed < voiceMinutesLimit;
}
