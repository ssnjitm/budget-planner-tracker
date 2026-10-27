import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/error/exceptions.dart' as app;
import '../../domain/entities/auth_user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  AuthUser? get currentUser => _toEntity(_client.auth.currentUser);

  Stream<AuthUser?> get onAuthStateChange => _client.auth.onAuthStateChange
      .map((event) => _toEntity(event.session?.user))
      .distinct();

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const app.AuthException('Could not sign in. Please try again.');
      }
      return _toEntity(user)!;
    } on AuthException catch (error) {
      throw _mapException(error);
    }
  }

  Future<AuthUser?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName == null ? null : {'display_name': displayName},
      );
      if (response.session == null) {
        return null;
      }
      return _toEntity(response.user);
    } on AuthException catch (error) {
      throw _mapException(error);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConstants.authCallbackUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const app.AuthException(
          'Could not open Google sign-in. Please try again.',
        );
      }
    } on AuthException catch (error) {
      throw _mapException(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw _mapException(error);
    }
  }

  app.AuthException _mapException(AuthException error) {
    return app.AuthException(
      error.message,
      statusCode: int.tryParse(error.statusCode ?? ''),
    );
  }

  AuthUser? _toEntity(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: _metadataValue(user, const [
        'display_name',
        'full_name',
        'name',
      ]),
      avatarUrl: _metadataValue(user, const ['avatar_url', 'picture']),
    );
  }

  String? _metadataValue(User user, List<String> keys) {
    final metadata = user.userMetadata;
    if (metadata == null) {
      return null;
    }
    for (final key in keys) {
      final value = metadata[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
