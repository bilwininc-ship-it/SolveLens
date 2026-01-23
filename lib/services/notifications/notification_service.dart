import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';

/// Top-level background message handler
/// Must be a top-level function for background execution
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.log('Background message received: ${message.messageId}');
  Logger.log('Title: ${message.notification?.title}');
  Logger.log('Body: ${message.notification?.body}');
}

/// Notification Service - FCM Push Notifications Manager
/// Features:
/// - Permission management (iOS/Android)
/// - Topic subscription ('all_users')
/// - Foreground & Background message handling
/// - Web platform guards
class NotificationService {
  static FirebaseMessaging? _messaging;
  static bool _isInitialized = false;

  /// Initialize notification service
  /// Should be called in main.dart after Firebase initialization
  static Future<void> initialize() async {
    // Web guard - FCM has limited support on web
    if (kIsWeb) {
      Logger.log('Notifications: Web platform detected - FCM limited support');
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;
      
      // Request permissions
      await requestPermission();
      
      // Configure background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Setup foreground message listener
      _setupForegroundListener();
      
      // Setup message interaction handlers
      _setupMessageInteractionHandlers();
      
      // Subscribe to all_users topic
      await subscribeToAllUsers();
      
      // Get and log FCM token (useful for testing)
      final token = await getToken();
      if (token != null) {
        Logger.log('FCM Token: $token');
      }
      
      _isInitialized = true;
      Logger.log('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('NotificationService initialization failed', error: e);
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Request notification permissions
  /// iOS: Shows native permission dialog
  /// Android: Automatically granted
  static Future<bool> requestPermission() async {
    if (_messaging == null || kIsWeb) return false;

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      if (isGranted) {
        Logger.log('Notification permission: GRANTED');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Logger.log('Notification permission: PROVISIONAL');
      } else {
        Logger.log('Notification permission: DENIED');
      }

      return isGranted;
    } catch (e) {
      Logger.error('Failed to request notification permission', error: e);
      return false;
    }
  }

  /// Setup foreground message listener
  /// Shows in-app notification when app is open
  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.log('Foreground message received: ${message.messageId}');
      
      final notification = message.notification;
      if (notification != null) {
        Logger.log('Notification - Title: ${notification.title}');
        Logger.log('Notification - Body: ${notification.body}');
        
        // Trigger callback for UI to show in-app notification
        _onForegroundMessageCallback?.call(message);
      }

      // Log data payload if present
      if (message.data.isNotEmpty) {
        Logger.log('Message data: ${message.data}');
      }
    });
  }

  /// Callback for foreground messages (to be set by UI)
  static void Function(RemoteMessage)? _onForegroundMessageCallback;

  /// Set callback for foreground messages
  /// Usage: NotificationService.onForegroundMessage = (message) { ... }
  static set onForegroundMessage(void Function(RemoteMessage) callback) {
    _onForegroundMessageCallback = callback;
  }

  /// Setup message interaction handlers
  /// Handles notification taps when app is in background/terminated
  static void _setupMessageInteractionHandlers() {
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.log('Notification opened app from background: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Logger.log('Notification opened app from terminated state: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle notification tap
  /// Override this method to add custom navigation logic
  static void _handleNotificationTap(RemoteMessage message) {
    Logger.log('Handling notification tap: ${message.data}');
    
    // TODO: Add navigation logic based on message.data
    // Example:
    // if (message.data['type'] == 'new_feature') {
    //   navigatorKey.currentState?.pushNamed('/feature-details');
    // }
  }

  /// Subscribe to 'all_users' topic
  /// All users receive broadcast notifications
  static Future<void> subscribeToAllUsers() async {
    if (_messaging == null || kIsWeb) return;

    try {
      await _messaging!.subscribeToTopic('all_users');
      Logger.log('Subscribed to topic: all_users');
      
      // Update Firestore user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationsEnabled': true,
          'subscribedTopics': FieldValue.arrayUnion(['all_users']),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Logger.error('Failed to subscribe to all_users topic', error: e);
    }
  }

  /// Unsubscribe from 'all_users' topic
  static Future<void> unsubscribeFromAllUsers() async {
    if (_messaging == null || kIsWeb) return;

    try {
      await _messaging!.unsubscribeFromTopic('all_users');
      Logger.log('Unsubscribed from topic: all_users');
      
      // Update Firestore user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationsEnabled': false,
          'subscribedTopics': FieldValue.arrayRemove(['all_users']),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Logger.error('Failed to unsubscribe from all_users topic', error: e);
    }
  }

  /// Toggle notifications on/off
  static Future<void> toggleNotifications(bool enable) async {
    if (enable) {
      await subscribeToAllUsers();
    } else {
      await unsubscribeFromAllUsers();
    }
  }

  /// Get FCM token
  /// Useful for testing and server-side targeting
  static Future<String?> getToken() async {
    if (_messaging == null || kIsWeb) return null;

    try {
      final token = await _messaging!.getToken();
      return token;
    } catch (e) {
      Logger.error('Failed to get FCM token', error: e);
      return null;
    }
  }

  /// Get current notification settings from Firestore
  static Future<bool> getNotificationSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['notificationsEnabled'] ?? true;
      }
      return true;
    } catch (e) {
      Logger.error('Failed to get notification settings', error: e);
      return true;
    }
  }

  /// Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    if (_messaging == null || kIsWeb) return;

    try {
      await _messaging!.deleteToken();
      Logger.log('FCM token deleted');
    } catch (e) {
      Logger.error('Failed to delete FCM token', error: e);
    }
  }

  /// Check if notifications are initialized
  static bool get isInitialized => _isInitialized;

  /// Get messaging instance (for advanced usage)
  static FirebaseMessaging? get messaging => _messaging;
}
