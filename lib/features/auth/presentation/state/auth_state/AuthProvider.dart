// lib/features/auth/presentation/state_management/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthNotifier.dart';
import 'package:pharma_app/features/auth/presentation/state/auth_state/AuthState.dart';
import 'package:pharma_app/features/auth/services/auth_remote_service.dart';


final authServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService();
});

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
