import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  if (!ref.watch(supabaseEnabledProvider)) {
    return AuthNotifier.local();
  }
  return AuthNotifier(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(storageProvider),
    database: ref.watch(appDatabaseProvider),
  );
});
