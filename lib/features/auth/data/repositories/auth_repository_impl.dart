import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remote}) : _remote = remote;

  final AuthRemoteDataSource _remote;

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Stream<AuthUser?> get onAuthStateChange => _remote.onAuthStateChange;

  @override
  TaskEither<Failure, AuthUser> signIn({
    required String email,
    required String password,
  }) {
    return TaskEither.tryCatch(
      () => _remote.signIn(email: email, password: password),
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, AuthUser?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return TaskEither.tryCatch(
      () => _remote.signUp(
        email: email,
        password: password,
        displayName: displayName,
      ),
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, void> signInWithGoogle() {
    return TaskEither.tryCatch(
      _remote.signInWithGoogle,
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, void> signOut() {
    return TaskEither.tryCatch(
      _remote.signOut,
      (error, stackTrace) => handleError(error),
    );
  }
}
