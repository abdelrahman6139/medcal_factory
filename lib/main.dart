import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 مهم
import 'package:pharma_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pharma_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:pharma_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_shell.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
const bool showOnboardingEveryLaunchInDebug =
true; // 👈 لو خليتها false هيرجع للوضع العادي

Future<bool> _loadOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();

  // في وضع التطوير: نمسح الفلاج كل تشغيل
  if (kDebugMode && showOnboardingEveryLaunchInDebug) {
    await prefs.remove('onboarding_done');
  }

  return prefs.getBool('onboarding_done') ?? false;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope( // ⬅️ Wrap your app here
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadOnboardingDone(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final onboardingDone = snap.data!;
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          home:  SplashScreen(),
          routes: {
            '/login': (c) => const LoginScreen(),
            '/app': (c) => const BaseShell(),
            '/onboarding': (c) => const OnboardingScreen(),
          },
        );
      },
    );
  }
}