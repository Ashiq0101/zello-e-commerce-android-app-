import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/dashboard/application/settings_provider.dart';

import 'package:firebase_core/firebase_core.dart';
// TODO: Uncomment the following import after running flutterfire configure
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // Initialize Firebase First
  await Firebase.initializeApp(
    // TODO: Uncomment the options below after running flutterfire configure
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: ZelloApp(initialDarkMode: isDarkMode),
    ),
  );
}

class ZelloApp extends ConsumerWidget {
  final bool initialDarkMode;
  const ZelloApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final isDarkMode = settingsAsync.value?.isDarkMode ?? initialDarkMode;

    return MaterialApp.router(
      title: 'Zello',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
