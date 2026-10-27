import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthRepository repository,
    required StorageService storage,
    required AppDatabase database,
  }) : _repository = repository,
       _storage = storage,
       _database = database,
       super(const AuthState()) {
    final repository = _repository;
    if (repository != null) {
      _subscription = repository.onAuthStateChange.listen(
        _handleAuthUser,
        onError: _handleStreamError,
      );
      unawaited(_bootstrap());
    }
  }

  AuthNotifier.local()
    : _repository = null,
      _storage = null,
      _database = null,
      super(const AuthState.local());

  final AuthRepository? _repository;
  final StorageService? _storage;
  final AppDatabase? _database;
  StreamSubscription<AuthUser?>? _subscription;

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  Future<void> signIn({required String email, required String password}) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _set(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await SignIn(
      repository,
    ).call(email: email, password: password).run();
    await result.fold<Future<void>>((failure) async {
      _set(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyMessage(failure),
        ),
      );
    }, _admit);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _set(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await SignUp(
      repository,
    ).call(email: email, password: password, displayName: displayName).run();
    await result.fold<Future<void>>(
      (failure) async {
        _set(
          state.copyWith(
            isSubmitting: false,
            errorMessage: _friendlyMessage(failure),
          ),
        );
      },
      (user) async {
        if (user == null) {
          _set(
            const AuthState(
              status: AuthStatus.unauthenticated,
              infoMessage:
                  'Check your email to confirm your account, then sign in.',
            ),
          );
          return;
        }
        await _admit(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _set(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await SignInWithGoogle(repository).call().run();
    result.fold(
      (failure) => _set(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyMessage(failure),
        ),
      ),
      (_) => _set(
        state.copyWith(
          isSubmitting: false,
          infoMessage:
              'Complete Google sign-in in your browser, then return to '
              'PocketBudget.',
        ),
      ),
    );
  }

  Future<void> signOut() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _set(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await SignOut(repository).call().run();
    result.fold(
      (failure) => _set(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyMessage(failure),
        ),
      ),
      (_) => _set(const AuthState(status: AuthStatus.unauthenticated)),
    );
  }

  Future<void> _bootstrap() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final user = repository.currentUser;
    if (user == null) {
      _set(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    await _admit(user);
  }

  void _handleAuthUser(AuthUser? user) {
    if (user == null) {
      _set(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    unawaited(_admit(user));
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    LoggerService.error('Auth state stream failed', error, stackTrace);
  }

  Future<void> _admit(AuthUser user) async {
    try {
      await _ensureLocalOwner(user);
      _set(AuthState(status: AuthStatus.authenticated, user: user));
    } on Object catch (error, stackTrace) {
      LoggerService.error(
        'Failed to prepare local user data',
        error,
        stackTrace,
      );
      _set(
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage:
              'Could not prepare local data for this account. Please try again.',
        ),
      );
    }
  }

  Future<void> _ensureLocalOwner(AuthUser user) async {
    final storage = _storage;
    final database = _database;
    if (storage == null || database == null) {
      return;
    }

    final previousUserId = await storage.read(AppConstants.userIdKey);
    if (previousUserId == user.id) {
      return;
    }

    if (previousUserId != null) {
      await database.clearUserData();
      await storage.delete(AppConstants.settingsKey);
    }

    await storage.write(AppConstants.userIdKey, user.id);
  }

  void _set(AuthState next) {
    if (mounted) {
      state = next;
    }
  }

  String _friendlyMessage(Failure failure) {
    final message = failure.message;
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Confirm your email address before signing in.';
    }
    if (normalized.contains('user already registered')) {
      return 'An account with this email already exists. Sign in instead.';
    }
    if (normalized.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    if (normalized.contains('rate limit') || normalized.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return message;
  }
}
