import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/constants/colors.dart';
import 'package:pharma_app/base_shell.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthNotifier.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // 🔔 Listen for auth changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      print("STATE CHANGED: $next");

      if (next is AuthAuthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BaseShell()),
              (_) => false,
        );
      } else if (next is AuthError) {
        // 👇 Just print errors to console
        print("AUTH ERROR: ${next.message}");
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account so you can explore all the existing jobs',
                  style: TextStyle(fontSize: 16, color: AppColors.subtitle),
                ),
                const SizedBox(height: 32),

                // 👇 Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: authState is AuthLoading
                        ? null
                        : () {
                      FocusScope.of(context).unfocus();

                      if (_passwordController.text !=
                          _confirmController.text) {
                        print("AUTH ERROR: Passwords do not match"); // 👈 console only
                        return;
                      }

                      ref.read(authNotifierProvider.notifier).register(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmController.text.trim(), // 👈 send confirm too
                      );
                    },
                    child: authState is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Sign up',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Already have an account",
                      style: TextStyle(color: AppColors.subtitle),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    "Or continue with",
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                ),
                const SizedBox(height: 16),

                // Social Media Icons (placeholders)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 32, color: AppColors.text),
                    SizedBox(width: 24),
                    Icon(Icons.facebook, size: 28, color: AppColors.text),
                    SizedBox(width: 24),
                    Icon(Icons.apple, size: 28, color: AppColors.text),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
