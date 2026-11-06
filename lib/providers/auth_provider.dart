
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String _userRole = 'student';
  bool _isCheckingRole = false;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _userRole = 'student';

      if (user != null && user.emailVerified) {
        loadUserRole();
      } else {
        notifyListeners();
      }
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  String get userRole => _userRole;
  bool get isCheckingRole => _isCheckingRole;
  bool get isStaff => _userRole == 'staff';

  // Load the user's role from Firestore.
  Future<void> loadUserRole() async {
    if (_user == null || !_user!.emailVerified) return;

    _isCheckingRole = true;
    notifyListeners();

    try {
      _userRole = await _userService.getUserRole(_user!.uid);
    } catch (e) {
      debugPrint('Could not load user role: $e');
      _userRole = 'student';
    } finally {
      _isCheckingRole = false;
      notifyListeners();
    }
  }

  // Register a new user.
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

  // Log in an existing user.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      if (credential.user != null &&
          credential.user!.emailVerified) {
        await _userService.createUserProfile(credential.user!);
        await loadUserRole();
      }

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed.';
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Log out.
  Future<void> logout() async {
    await _authService.logout();
    _userRole = 'student';
    notifyListeners();
  }

  // Update loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Resend verification email.
  Future<void> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          e.message ?? 'Could not send verification email.';
    }

    notifyListeners();
  }

  // Refresh email verification status.
  Future<void> checkEmailVerification() async {
    await _user?.reload();

    _user = FirebaseAuth.instance.currentUser;

    if (_user != null && _user!.emailVerified) {
      await _userService.createUserProfile(_user!);
      await loadUserRole();
    }

    notifyListeners();
  }
}
