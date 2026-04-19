import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;
  bool _isLoading = false;

  void _sendResetLink() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset Password', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                _isSent 
                    ? 'A password reset link has been sent to your email.'
                    : 'Enter the email associated with your account and we\'ll send an email with instructions to reset your password.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (!_isSent) ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Reset Link'),
                  ),
                ),
              ] else ...[
                 SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
