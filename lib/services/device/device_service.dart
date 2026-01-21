import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseFirestore _firestore;

  DeviceService(this._firestore);

  /// Gets a unique device fingerprint/ID
  Future<String> getDeviceId() async {
    try {
      // Web platform: use browser fingerprint
      if (kIsWeb) {
        return _getWebDeviceId();
      }
      
      // Mobile platforms - dart:io is only available on non-web platforms
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Create a unique fingerprint from multiple device attributes
        return '${androidInfo.id}_${androidInfo.model}_${androidInfo.device}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      return 'unknown_platform';
    } catch (e) {
      throw DeviceServiceException('Failed to get device ID: $e');
    }
  }

  /// Gets web device ID based on browser fingerprint
  String _getWebDeviceId() {
    if (!kIsWeb) return 'not_web';
    
    try {
      // For web, use a combination of available browser properties
      // Note: This is a simplified version. In production, consider using
      // a proper fingerprinting library or localStorage for consistency
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = timestamp.hashCode.abs();
      
      // You can enhance this with localStorage to persist the ID
      return 'web_device_$randomId';
    } catch (e) {
      return 'web_unknown';
    }
  }

  /// Checks if device has exceeded daily limit
  Future<bool> hasDeviceExceededDailyLimit(String deviceId, int dailyLimit) async {
    try {
      final deviceDoc = await _firestore
          .collection('device_limits')
          .doc(deviceId)
          .get();

      if (!deviceDoc.exists) {
        return false; // New device, hasn't exceeded limit
      }

      final data = deviceDoc.data()!;
      final lastUpdate = (data['lastQuestionDate'] as Timestamp?)?.toDate();
      final questionsUsedToday = data['questionsUsedToday'] ?? 0;
      final today = DateTime.now();

      // Check if it's a new day (reset counter)
      if (lastUpdate == null || !_isSameDay(lastUpdate, today)) {
        return false; // New day, hasn't exceeded limit
      }

      // Check against limit
      return questionsUsedToday >= dailyLimit;
    } catch (e) {
      throw DeviceServiceException('Failed to check device limit: $e');
    }
  }

  /// Increments device's daily question counter
  Future<void> incrementDeviceQuestionCounter(String deviceId) async {
    try {
      final deviceRef = _firestore.collection('device_limits').doc(deviceId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(deviceRef);

        if (!snapshot.exists) {
          // Create new device document
          transaction.set(deviceRef, {
            'deviceId': deviceId,
            'questionsUsedToday': 1,
            'lastQuestionDate': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = snapshot.data()!;
          final lastUpdate = (data['lastQuestionDate'] as Timestamp?)?.toDate();
          final today = DateTime.now();

          if (lastUpdate == null || !_isSameDay(lastUpdate, today)) {
            // New day, reset counter
            transaction.update(deviceRef, {
              'questionsUsedToday': 1,
              'lastQuestionDate': FieldValue.serverTimestamp(),
            });
          } else {
            // Same day, increment counter
            transaction.update(deviceRef, {
              'questionsUsedToday': FieldValue.increment(1),
              'lastQuestionDate': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      throw DeviceServiceException('Failed to increment device counter: $e');
    }
  }

  /// Checks if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Gets device info for logging/debugging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return {
          'platform': 'web',
          'deviceId': await getDeviceId(),
        };
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'deviceId': await getDeviceId(),
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'deviceId': await getDeviceId(),
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      return {
        'platform': 'unknown',
        'deviceId': await getDeviceId(),
      };
    } catch (e) {
      return {
        'platform': 'error',
        'error': e.toString(),
      };
    }
  }
}

class DeviceServiceException implements Exception {
  final String message;
  DeviceServiceException(this.message);

  @override
  String toString() => message;
}