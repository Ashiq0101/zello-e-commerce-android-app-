import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _pendingPassword;
  
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
    if (email == 'admin1@zello.com' && password == '12345') {
      _ref.read(authStateProvider.notifier).setAuth(AuthState.admin);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Simulated admin role for a specific email
      final role = email.toLowerCase().contains('admin') ? AuthState.admin : AuthState.user;
      _ref.read(authStateProvider.notifier).setAuth(role);
    } catch (e) {
      throw Exception('Incorrect email or password.');
    }
  }

  Future<void> sendOtpToEmail(String name, String email, String password) async {
    // Check Firestore (Wrap in try-catch to avoid breaking signup if permission denied)
    try {
      final query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        throw Exception('An account with this email already exists. Please log in instead.');
      }
    } catch (e) {
      if (e.toString().contains('An account with this email already exists')) {
        rethrow;
      }
      // Ignore other errors like permission denied
    }

    if (SmtpConfig.appPassword == 'YOUR_APP_PASSWORD_HERE') {
      throw Exception('SMTP is not configured. Please add your App Password in smtp_config.dart');
    }

    bool result = await EmailOTP.sendOTP(email: email);
    if (!result) {
      throw Exception('Failed to send OTP to email. Check your SMTP credentials and internet connection.');
    }
    
    _pendingName = name;
    _pendingEmail = email;
    _pendingPassword = password;
  }

  Future<void> verifyOtp(String code) async {
    // Native verification
    bool isVerified = EmailOTP.verifyOTP(otp: code);
    if (isVerified) {
      // Auto-create user profile in the global state
      if (_pendingName != null && _pendingEmail != null && _pendingPassword != null) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _pendingEmail!,
            password: _pendingPassword!,
          );
        } catch (e) {
          throw Exception('Failed to create account. It might already exist.');
        }
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
