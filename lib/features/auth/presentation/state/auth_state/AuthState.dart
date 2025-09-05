// lib/features/auth/presentation/state/auth_state/AuthState.dart
import 'package:pharma_app/features/auth/models/user.dart';

/// Authentication State (using sealed classes)
sealed class AuthState {
  const AuthState();
}

// -------- Base States --------
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// -------- Signup States --------
class AuthSignupSuccess extends AuthState {
  const AuthSignupSuccess();
}

class AuthVerificationRequired extends AuthState {
  const AuthVerificationRequired();
}

class AuthVerifyingCode extends AuthState {
  const AuthVerifyingCode();
}

// -------- Password Reset States --------
class AuthForgotPasswordSent extends AuthState {
  const AuthForgotPasswordSent();
}

class AuthVerifyingResetCode extends AuthState {
  const AuthVerifyingResetCode();
}

class AuthResetPasswordSuccess extends AuthState {
  const AuthResetPasswordSuccess();
}

// -------- Profile / Token Refresh --------
class AuthRefreshingToken extends AuthState {
  const AuthRefreshingToken();
}

class AuthProfileUpdating extends AuthState {
  const AuthProfileUpdating();
}

class AuthProfileUpdated extends AuthState {
  const AuthProfileUpdated();
}

// -------- Session / Security --------
class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}

class AuthLocked extends AuthState {
  const AuthLocked();
}

class AuthDisabled extends AuthState {
  const AuthDisabled();
}
