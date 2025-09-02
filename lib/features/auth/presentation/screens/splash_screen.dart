import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/base_shell.dart';
import 'package:pharma_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthNotifier.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // 🔹 Check cached JWT and user
    final token = await _secureStorage.read(key: 'accessToken');
    final userJson = prefs.getString('user');

    // Optional splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (token != null && userJson != null) {
      try {
        final user = jsonDecode(userJson);
        // ✅ Update AuthNotifier state directly
        ref.read(authNotifierProvider.notifier).setAuthenticated(user, token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BaseShell()),
        );
        return;
      } catch (e) {
        // Token corrupted or invalid
        print("SplashScreen: Invalid cached user/token, clearing cache.");
        await _secureStorage.delete(key: 'accessToken');
        await prefs.remove('user');
      }
    }

    // First-time check
    if (isFirstTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      // Mark first-time as done
      await prefs.setBool('isFirstTime', false);
      return;
    }

    // Otherwise, go to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
