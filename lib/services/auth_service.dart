
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently signed-in user.
  User? get currentUser => _auth.currentUser;

  // Listen for authentication changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user!.sendEmailVerification();

    return credential;
  }

  // Log in an existing user.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (!credential.user!.emailVerified) {
      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before logging in.',
      );
    }

    return credential;
  }

  // Resend the verification email.
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Log out.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
