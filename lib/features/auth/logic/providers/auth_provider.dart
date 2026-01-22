import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firebase/firebase_service.dart';
import '../../../../core/utils/logger.dart';

/// Auth Provider - Manages Authentication State
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  bool _isFirstTime = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isFirstTime => _isFirstTime;

  AuthProvider() {
    // Listen to auth state changes
    FirebaseService.auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      
      // Check if user is first time
      if (user != null) {
        await checkFirstTimeUser();
      }
      
      notifyListeners();
    });
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.signInWithEmail(email.trim(), password);
      
      // Update last login time
      if (_currentUser != null) {
        await FirebaseService.firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update({
          'lastLoginAt': DateTime.now(),
        });
      }

      Logger.log('Sign in successful: ${_currentUser?.email}');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFirebaseErrorMessage(e));
      Logger.error('Sign in failed', error: e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      Logger.error('Sign in failed', error: e);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp(String email, String password, {String? displayName}) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await FirebaseService.signUpWithEmail(
        email.trim(),
        password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      _currentUser = credential.user;
      
      // Create user document with isFirstTime flag
      if (_currentUser != null) {
        await FirebaseService.firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
          'email': _currentUser!.email,
          'displayName': displayName ?? '',
          'isFirstTime': true,
          'credits': 3,
          'createdAt': DateTime.now(),
          'lastLoginAt': DateTime.now(),
        });
        _isFirstTime = true;
      }
      
      Logger.log('Sign up successful: ${_currentUser?.email}');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFirebaseErrorMessage(e));
      Logger.error('Sign up failed', error: e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      Logger.error('Sign up failed', error: e);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.signOut();
      _currentUser = null;
      _setLoading(false);
      Logger.log('Sign out successful');
    } catch (e) {
      _setLoading(false);
      _setError('Failed to sign out. Please try again.');
      Logger.error('Sign out failed', error: e);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.resetPassword(email.trim());
      
      Logger.log('Password reset email sent to: $email');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFirebaseErrorMessage(e));
      Logger.error('Password reset failed', error: e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to send reset email. Please try again.');
      Logger.error('Password reset failed', error: e);
      return false;
    }
  }

  /// Check if user is first time
  Future<void> checkFirstTimeUser() async {
    if (_currentUser == null) return;

    try {
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        _isFirstTime = data?['isFirstTime'] ?? false;
      } else {
        // If user document doesn't exist, create it
        await FirebaseService.firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
          'email': _currentUser!.email,
          'displayName': _currentUser!.displayName ?? '',
          'isFirstTime': true,
          'credits': 3,
          'createdAt': DateTime.now(),
          'lastLoginAt': DateTime.now(),
        });
        _isFirstTime = true;
      }
      
      notifyListeners();
      Logger.log('First time check: $_isFirstTime for user ${_currentUser?.email}');
    } catch (e) {
      Logger.error('Failed to check first time user', error: e);
      _isFirstTime = false;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (_currentUser == null) return;

    try {
      await FirebaseService.firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'isFirstTime': false,
        'onboardingCompletedAt': DateTime.now(),
      });

      _isFirstTime = false;
      notifyListeners();
      Logger.log('Onboarding completed for user: ${_currentUser?.email}');
    } catch (e) {
      Logger.error('Failed to complete onboarding', error: e);
    }
  }

  /// Get user-friendly Firebase error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return e.message ?? 'Authentication failed. Please try again';
    }
  }
}