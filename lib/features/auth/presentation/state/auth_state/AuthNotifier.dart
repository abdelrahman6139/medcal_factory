// lib/features/auth/presentation/state_management/auth_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/features/auth/models/user.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteService _authService;

  AuthNotifier(this._authService) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      final user = result['user'] as User;
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void logout() {
    state = const AuthUnauthenticated();
  }
}
