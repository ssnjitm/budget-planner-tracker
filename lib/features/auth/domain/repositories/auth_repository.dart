import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get onAuthStateChange;

  TaskEither<Failure, AuthUser> signIn({
    required String email,
    required String password,
  });

  TaskEither<Failure, AuthUser?> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  TaskEither<Failure, void> signInWithGoogle();

  TaskEither<Failure, void> signOut();
}
