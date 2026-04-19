import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo placeholder / typographic design
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'Z',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Zello',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Discover premium products tailored to your aesthetic.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textLight,
                    ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.push('/signup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
