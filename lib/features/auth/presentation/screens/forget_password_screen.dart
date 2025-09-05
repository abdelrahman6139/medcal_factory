import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/constants/colors.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthNotifier.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    // react to errors / success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message.toString().replaceFirst('Exception: ', ''))),
        );
      }
      if (state is AuthResetPasswordSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully. Please login.')),
        );
        Navigator.of(context).pop(); // back to login
      }
    });

    final loading = state is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Forgot Password", style: TextStyle(color: AppColors.text)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: _buildBody(context, state, loading),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state, bool loading) {
    // STEP 1: ask for email (initial / unauth / error)
    if (state is AuthInitial ||
        state is AuthUnauthenticated ||
        state is AuthError) {
      return _stepEmail(loading);
    }

    // STEP 2: code sent -> show code entry
    if (state is AuthForgotPasswordSent) {
      return _stepCode(loading);
    }

    // STEP 3: after verification -> show new password entry
    if (state is AuthVerifyingResetCode) {
      return _stepNewPassword(loading);
    }

    // fallback: show email step
    return _stepEmail(loading);
  }

  // ---------- STEP 1: Email ----------
  Widget _stepEmail(bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'No worries!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address below and we will send you a code to reset password.',
          style: TextStyle(fontSize: 14, color: AppColors.subtitle),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail',
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
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: loading
                ? null
                : () async {
                    final email = _emailCtrl.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid email')),
                      );
                      return;
                    }
                    await ref.read(authNotifierProvider.notifier).forgotPassword(email);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset code sent!')),
                      );
                    }
                  },
            child: loading
                ? const CircularProgressIndicator.adaptive()
                : const Text('Send', style: TextStyle(color: AppColors.white)),
          ),
        ),
      ],
    );
  }

  // ---------- STEP 2: Code ----------
  Widget _stepCode(bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        const Text('Enter the 6‑digit code we sent to your email.',
            style: TextStyle(fontSize: 14, color: AppColors.subtitle)),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Reset code',
            counterText: '',
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
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: loading
                ? null
                : () async {
                    final code = _codeCtrl.text.trim();
                    if (code.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter the 6‑digit code')),
                      );
                      return;
                    }
                    await ref.read(authNotifierProvider.notifier).verifyResetCode(code);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code verified!')),
                      );
                    }
                  },
            child: loading
                ? const CircularProgressIndicator.adaptive()
                : const Text('Verify', style: TextStyle(color: AppColors.white)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: loading
              ? null
              : () async {
                  final email = _emailCtrl.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Enter email in step 1 first')));
                    return;
                  }
                  await ref.read(authNotifierProvider.notifier).forgotPassword(email);
                },
          child: const Text('Resend code'),
        ),
      ],
    );
  }

  // ---------- STEP 3: New Password ----------
  Widget _stepNewPassword(bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Set a new password',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        const Text('Create a strong password you can remember.',
            style: TextStyle(fontSize: 14, color: AppColors.subtitle)),
        const SizedBox(height: 24),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New password',
            labelStyle: const TextStyle(color: AppColors.textGray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pass2Ctrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm new password',
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
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: loading
                ? null
                : () async {
                    final email = _emailCtrl.text.trim();
                    final p1 = _passCtrl.text.trim();
                    final p2 = _pass2Ctrl.text.trim();

                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Missing email from step 1')));
                      return;
                    }
                    if (p1.length < 6) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Min 6 characters')));
                      return;
                    }
                    if (p1 != p2) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                      return;
                    }

                    await ref.read(authNotifierProvider.notifier).resetPassword(email, p1);
                  },
            child: loading
                ? const CircularProgressIndicator.adaptive()
                : const Text('Update Password', style: TextStyle(color: AppColors.white)),
          ),
        ),
      ],
    );
  }
}
