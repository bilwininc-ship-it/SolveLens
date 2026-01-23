import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../../core/utils/logger.dart';

/// Firebase Service - Centralized Firebase Management
/// Handles: Auth, Firestore, Analytics, Crashlytics, Remote Config, Messaging
class FirebaseService {
  // Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseCrashlytics? _crashlytics;
  static FirebaseRemoteConfig? _remoteConfig;
  static FirebaseMessaging? _messaging;

  // Getters
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAnalytics get analytics => _analytics;
  static FirebaseCrashlytics? get crashlytics => _crashlytics;
  static FirebaseRemoteConfig? get remoteConfig => _remoteConfig;
  static FirebaseMessaging? get messaging => _messaging;

  /// Initialize Firebase and all services
  static Future<void> initialize() async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.log('Firebase Core initialized successfully');

      // Initialize Crashlytics (Mobile only)
      if (!kIsWeb) {
        _crashlytics = FirebaseCrashlytics.instance;
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        Logger.log('Crashlytics initialized');
      }

      // Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig!.fetchAndActivate();
      Logger.log('Remote Config initialized');

      // Initialize Cloud Messaging (Mobile only)
      if (!kIsWeb) {
        _messaging = FirebaseMessaging.instance;
        await _requestNotificationPermission();
        Logger.log('Firebase Messaging initialized');
      }

      // Set Firestore settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      Logger.log('All Firebase services initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Firebase initialization failed', error: e);
      _crashlytics?.recordError(e, stackTrace);
      rethrow;
    }
  }

  /// Request notification permissions (iOS specific)
  static Future<void> _requestNotificationPermission() async {
    if (_messaging == null) return;

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.log('Notification permission granted');
    } else {
      Logger.log('Notification permission denied');
    }
  }

  // ==================== AUTH METHODS ====================

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.log('User signed in: ${credential.user?.email}');
      return credential;
    } catch (e) {
      Logger.error('Sign in failed', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Sign up with email and password
  static Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.log('User signed up: ${credential.user?.email}');
      
      // Create user document in Firestore
      await createUserDocument(credential.user!);
      
      return credential;
    } catch (e) {
      Logger.error('Sign up failed', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      Logger.log('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Logger.log('Password reset email sent to: $email');
    } catch (e) {
      Logger.error('Password reset failed', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // ==================== FIRESTORE METHODS ====================

  /// Create user document after signup
  static Future<void> createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'credits': 3, // Initial credits
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isFirstTime': true,
        'notificationsEnabled': true,
        'last_ad_claim_at': null, // For rewarded ad cooldown tracking
      });
      Logger.log('User document created: ${user.uid}');
    } catch (e) {
      Logger.error('Failed to create user document', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Get user document
  static Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Update user credits
  static Future<void> updateCredits(String uid, int credits) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'credits': credits,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.log('Credits updated for user: $uid');
    } catch (e) {
      Logger.error('Failed to update credits', error: e);
      _crashlytics?.recordError(e, null);
      rethrow;
    }
  }

  /// Collection references
  static CollectionReference users() => _firestore.collection('users');
  static CollectionReference analyses() => _firestore.collection('analyses');
  static CollectionReference history() => _firestore.collection('history');

  // ==================== REMOTE CONFIG METHODS ====================

  /// Get remote config value
  static bool getConfigBool(String key) {
    return _remoteConfig?.getBool(key) ?? false;
  }

  static String getConfigString(String key) {
    return _remoteConfig?.getString(key) ?? '';
  }

  static int getConfigInt(String key) {
    return _remoteConfig?.getInt(key) ?? 0;
  }

  // Check maintenance mode
  static bool get isMaintenanceMode => getConfigBool('is_maintenance');
  
  // Get app version requirement
  static String get requiredAppVersion => getConfigString('app_version');
  
  // Get announcement message
  static String get announcementMessage => getConfigString('announcement_message');
}
