
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isSending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    await context.read<AuthProvider>().checkEmailVerification();

    if (!mounted) return;

    setState(() => _isChecking = false);

    final auth = context.read<AuthProvider>();

    if (auth.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Check your inbox.'),
        ),
      );
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isSending = true);

    await context.read<AuthProvider>().resendVerificationEmail();

    if (!mounted) return;

    setState(() => _isSending = false);

    final error = context.read<AuthProvider>().errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Verification email sent. Check your inbox.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check Your Inbox',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We sent you a verification link. '
                  'Open the email and verify your address, '
                  'then return here.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerification,
                    child: _isChecking
                        ? const CircularProgressIndicator()
                        : const Text('I Have Verified My Email'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSending ? null : _resendEmail,
                  child: _isSending
                      ? const CircularProgressIndicator()
                      : const Text('Resend Verification Email'),
                ),
                TextButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
