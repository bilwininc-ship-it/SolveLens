import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    // TODO: Implement login logic
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    // TODO: Implement logout logic
    _isAuthenticated = false;
    notifyListeners();
  }
}