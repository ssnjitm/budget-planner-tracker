import 'package:equatable/equatable.dart';

import 'auth_user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  const AuthState.local()
    : status = AuthStatus.authenticated,
      user = AuthUser.local,
      isSubmitting = false,
      errorMessage = null,
      infoMessage = null;

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get isBusy => status == AuthStatus.unknown || isSubmitting;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isSubmitting,
    errorMessage,
    infoMessage,
  ];
}
