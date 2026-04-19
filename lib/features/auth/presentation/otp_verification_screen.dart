import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/auth/application/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _verifyOtp() async {
    if (_codeController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider).verifyOtp(_codeController.text);
      // Wait a frame so that navigation state resolves. As soon as setAuth(true) occurs,
      // the GoRouter will automatically redirect to the dashboard, so we don't need to context.go manually. 
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
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
              Text('Verify Email', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a verification code to:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email.isNotEmpty ? widget.email : 'your email address',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(letterSpacing: 16),
                  counterText: '',
                ),
              ),
              if (_errorMessage != null) ...[
                 const SizedBox(height: 12),
                 Center(
                   child: Text(
                     _errorMessage!,
                     style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                   ),
                 ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify & Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
