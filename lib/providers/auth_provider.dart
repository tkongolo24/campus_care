
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authService.register(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authService.login(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // Resend the verification email.
Future<void> resendVerificationEmail() async {
  try {
    await _authService.resendVerificationEmail();
    _errorMessage = null;
  } on FirebaseAuthException catch (e) {
    _errorMessage = e.message ?? 'Could not send verification email.';
  }

  notifyListeners();
}

// Refresh the user's verification status.
Future<void> checkEmailVerification() async {
  await _user?.reload();

  _user = FirebaseAuth.instance.currentUser;
  notifyListeners();
}
}


