import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  
  int _remainingCredits = 0;
  String? _userId;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  int get remainingCredits => _remainingCredits;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;
  String? get userId => _userId;

  /// Initialize real-time listener for user document
  void startListening(String userId) {
    if (_userId == userId && _userSubscription != null) {
      // Already listening to this user
      return;
    }

    // Cancel previous subscription if exists
    stopListening();
    
    _userId = userId;
    _isLoading = true;
    // CRITICAL FIX: Defer notifyListeners to avoid setState during build
    // This prevents "setState() or markNeedsBuild() called during build" error
    Future.microtask(() => notifyListeners());

    // Set up real-time StreamSubscription on users/{userId} document
    _userSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
          (DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              _userData = snapshot.data() as Map<String, dynamic>?;
              _remainingCredits = _userData?['remaining_credits'] ?? 0;
              _isLoading = false;
              
              debugPrint('🔥 UserProvider: Credits updated to $_remainingCredits');
              notifyListeners();
            } else {
              // Document doesn't exist yet (new user)
              _remainingCredits = 0;
              _userData = null;
              _isLoading = false;
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('❌ UserProvider: Error listening to user document: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Stop listening to user document
  void stopListening() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _userId = null;
    _remainingCredits = 0;
    _userData = null;
    _isLoading = true;
  }

  /// Manual refresh (optional - streaming handles this automatically)
  Future<void> refreshCredits() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        _userData = doc.data();
        _remainingCredits = _userData?['remaining_credits'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error refreshing credits: $e');
    }
  }
  /// Deduct credits atomically from user's wallet
  /// Returns true if successful, false if insufficient credits
  Future<bool> useCredits(int amount) async {
    if (_userId == null) {
      debugPrint('❌ useCredits: No userId set');
      return false;
    }

    if (amount <= 0) {
      debugPrint('⚠️ useCredits: Invalid amount $amount');
      return false;
    }

    if (_remainingCredits < amount) {
      debugPrint('❌ useCredits: Insufficient credits. Need: $amount, Have: $_remainingCredits');
      return false;
    }

    try {
      // Atomic decrement using FieldValue.increment (negative for deduction)
      await _firestore.collection('users').doc(_userId).update({
        'remaining_credits': FieldValue.increment(-amount),
      });

      debugPrint('💰 useCredits: Successfully deducted $amount credits');
      // Real-time listener will automatically update _remainingCredits
      return true;
    } catch (e) {
      debugPrint('❌ useCredits: Error deducting credits: $e');
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
