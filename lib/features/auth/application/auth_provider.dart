import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_otp/email_otp.dart';
import 'package:zello/core/constants/smtp_config.dart';
import 'package:zello/features/admin/application/user_provider.dart';
import 'package:flutter/foundation.dart';

enum AuthState { unauthenticated, user, admin }

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.unauthenticated;

  void setAuth(AuthState authState) {
    state = authState;
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  String? _pendingName;
  String? _pendingEmail;
  
  AuthController(this._ref) {
    // Configure OTP details
    EmailOTP.config(
      appName: 'Zello',
      otpType: OTPType.numeric,
      emailTheme: EmailTheme.v1,
    );
    // Configure SMTP using the constants file
    EmailOTP.setSMTP(
      host: 'smtp.gmail.com',
      emailPort: EmailPort.port587,
      secureType: SecureType.tls,
      username: SmtpConfig.email,
      password: SmtpConfig.appPassword,
    );
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulated admin role for a specific email
    final role = email.toLowerCase().contains('admin') ? AuthState.admin : AuthState.user;
    _ref.read(authStateProvider.notifier).setAuth(role);
  }

  Future<void> sendOtpToEmail(String name, String email, String password) async {
    if (SmtpConfig.appPassword == 'YOUR_APP_PASSWORD_HERE') {
      throw Exception('SMTP is not configured. Please add your App Password in smtp_config.dart');
    }

    bool result = await EmailOTP.sendOTP(email: email);
    if (!result) {
      throw Exception('Failed to send OTP to email. Check your SMTP credentials and internet connection.');
    }
    
    _pendingName = name;
    _pendingEmail = email;
  }

  Future<void> verifyOtp(String code) async {
    // Native verification
    bool isVerified = EmailOTP.verifyOTP(otp: code);
    if (isVerified) {
      // Auto-create user profile in the global state
      if (_pendingName != null && _pendingEmail != null) {
         _ref.read(adminUserProvider.notifier).registerNewUser(_pendingName!, _pendingEmail!);
      }
      _ref.read(authStateProvider.notifier).setAuth(AuthState.user);
    } else {
      throw Exception('Invalid verification code. Please try again.');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _ref.read(authStateProvider.notifier).setAuth(AuthState.unauthenticated);
  }
}
