import 'package:fpdart/fpdart.dart';

import '../../../../core/common/extensions/string_extensions.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  TaskEither<Failure, AuthUser> call({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final failure = _validateCredentials(normalizedEmail, password);
    if (failure != null) {
      return TaskEither.left(failure);
    }
    return _repository.signIn(email: normalizedEmail, password: password);
  }
}

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  TaskEither<Failure, AuthUser?> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final failure = _validateCredentials(normalizedEmail, password);
    if (failure != null) {
      return TaskEither.left(failure);
    }
    final normalizedName = displayName?.trim();
    return _repository.signUp(
      email: normalizedEmail,
      password: password,
      displayName: normalizedName == null || normalizedName.isEmpty
          ? null
          : normalizedName,
    );
  }
}

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  TaskEither<Failure, void> call() => _repository.signInWithGoogle();
}

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  TaskEither<Failure, void> call() => _repository.signOut();
}

Failure? _validateCredentials(String email, String password) {
  if (!email.isValidEmail) {
    return const ValidationFailure('Enter a valid email address');
  }
  if (password.isEmpty) {
    return const ValidationFailure('Enter your password');
  }
  if (password.length < 6) {
    return const ValidationFailure('Password must be at least 6 characters');
  }
  return null;
}
