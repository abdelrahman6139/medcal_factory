// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_app/base_shell.dart';
import 'package:pharma_app/constants/colors.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';
import 'package:pharma_app/features/auth/services/AuthCache.dart';
import 'package:pharma_app/features/auth/models/user.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthNotifier.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'register_screen.dart';
import 'forget_password_screen.dart';

// Put your Web client ID (same one your backend verifies)
const String kGoogleWebClientId = '276810087339-0nnqjp1833s4andi8qtmqeefs1j65mh1.apps.googleusercontent.com';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isGoogleBusy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailPasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.login(email: email, password: pass);
  }

  Future<void> _handleGoogleLogin() async {
    if (_isGoogleBusy) return;
    setState(() => _isGoogleBusy = true);
    try {
      final google = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: kGoogleWebClientId,
      );
      final acc = await google.signIn();
      if (acc == null) return;
      final auth = await acc.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No ID token returned from Google.')),
          );
        }
        return;
      }

      // Exchange with backend
      final api = AuthRemoteService();
      final res = await api.googleLogin(idToken: idToken);
      final User user = res['user'] as User;
      final String token = res['token'] as String? ?? '';

      final cache = await AuthCache.create();
      await cache.saveUser(user);
      if (token.isNotEmpty) await cache.saveTokens(token);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BaseShell()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) async {
      if (next is AuthAuthenticated) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BaseShell()),
          (route) => false,
        );
      } else if (next is AuthError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Sign in to continue', style: TextStyle(color: AppColors.subtitle)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()));
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: authState is AuthLoading ? null : _handleEmailPasswordLogin,
                  child: authState is AuthLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isGoogleBusy ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata),
                  label: Text(_isGoogleBusy ? 'Connecting…' : 'Continue with Google'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      child: const Text('Create account'),
                    )
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
