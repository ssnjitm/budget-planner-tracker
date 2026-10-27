import 'dart:async';

import 'package:budget_planner_tracker/core/common/providers/core_providers.dart';
import 'package:budget_planner_tracker/core/constants/app_constants.dart';
import 'package:budget_planner_tracker/core/database/app_database.dart';
import 'package:budget_planner_tracker/core/database/tables.dart';
import 'package:budget_planner_tracker/core/error/failures.dart';
import 'package:budget_planner_tracker/core/services/storage_service.dart';
import 'package:budget_planner_tracker/features/auth/domain/entities/auth_state.dart';
import 'package:budget_planner_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:budget_planner_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:budget_planner_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  ProviderContainer buildContainer({
    required FakeAuthRepository repository,
    required FakeStorageService storage,
  }) {
    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(repository),
        storageProvider.overrideWithValue(storage),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);
    return container;
  }

  Future<void> waitForStatus(
    ProviderContainer container,
    AuthStatus expected,
  ) async {
    for (var attempt = 0; attempt < 100; attempt++) {
      if (container.read(authProvider).status == expected) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Auth status did not become ${expected.name}');
  }

  test('falls back to a local authenticated profile when unconfigured', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(authProvider);

    expect(state.status, AuthStatus.authenticated);
    expect(state.user?.isLocal, isTrue);
  });

  test(
    'first cloud sign-in claims local data and stores the user id',
    () async {
      final repository = FakeAuthRepository();
      final storage = FakeStorageService();
      final container = buildContainer(
        repository: repository,
        storage: storage,
      );

      await waitForStatus(container, AuthStatus.unauthenticated);

      repository.nextUser = const AuthUser(
        id: 'user-1',
        email: 'user@example.com',
      );
      await container
          .read(authProvider.notifier)
          .signIn(email: 'user@example.com', password: 'secret1');

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.id, 'user-1');
      expect(storage.values[AppConstants.userIdKey], 'user-1');
    },
  );

  test(
    'switching accounts clears local user data and reseeds categories',
    () async {
      final sqlite = await database.database;
      await sqlite.insert(Tables.transactions, {
        Cols.id: 'tx-1',
        Cols.categoryId: '22222222-2222-4222-8222-000000000001',
        Cols.type: 'expense',
        Cols.amountMinor: 1000,
        Cols.transactionDate: '2026-10-01',
        Cols.createdAt: '2026-10-01T00:00:00.000Z',
        Cols.updatedAt: '2026-10-01T00:00:00.000Z',
      });

      final storage = FakeStorageService({
        AppConstants.userIdKey: 'user-1',
        AppConstants.settingsKey: '{}',
      });
      final repository = FakeAuthRepository(
        current: const AuthUser(id: 'user-2', email: 'second@example.com'),
      );
      final container = buildContainer(
        repository: repository,
        storage: storage,
      );

      await waitForStatus(container, AuthStatus.authenticated);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(storage.values[AppConstants.userIdKey], 'user-2');
      expect(storage.values.containsKey(AppConstants.settingsKey), isFalse);
      expect(
        await sqlite.query(
          Tables.transactions,
          where: '${Cols.id} = ?',
          whereArgs: ['tx-1'],
        ),
        isEmpty,
      );
      expect(await sqlite.query(Tables.categories), hasLength(14));
    },
  );

  test('maps invalid credential errors to a friendly message', () async {
    final repository = FakeAuthRepository(
      signInFailure: const AuthFailure('Invalid login credentials'),
    );
    final container = buildContainer(
      repository: repository,
      storage: FakeStorageService(),
    );

    await waitForStatus(container, AuthStatus.unauthenticated);
    await container
        .read(authProvider.notifier)
        .signIn(email: 'user@example.com', password: 'wrong-password');

    final state = container.read(authProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.errorMessage, 'Incorrect email or password.');
  });

  test('signing out keeps the last owner id for the next launch', () async {
    final storage = FakeStorageService({AppConstants.userIdKey: 'user-1'});
    final repository = FakeAuthRepository(
      current: const AuthUser(id: 'user-1', email: 'user@example.com'),
    );
    final container = buildContainer(repository: repository, storage: storage);

    await waitForStatus(container, AuthStatus.authenticated);
    await container.read(authProvider.notifier).signOut();

    expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    expect(storage.values[AppConstants.userIdKey], 'user-1');
  });
}

class FakeStorageService extends StorageService {
  FakeStorageService([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.current, this.nextUser, this.signInFailure});

  AuthUser? current;
  AuthUser? nextUser;
  Failure? signInFailure;

  final _changes = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => current;

  @override
  Stream<AuthUser?> get onAuthStateChange => _changes.stream;

  @override
  TaskEither<Failure, AuthUser> signIn({
    required String email,
    required String password,
  }) {
    final failure = signInFailure;
    if (failure != null) {
      return TaskEither.left(failure);
    }
    final user = nextUser;
    if (user == null) {
      return TaskEither.left(const AuthFailure('No user returned'));
    }
    current = user;
    return TaskEither.right(user);
  }

  @override
  TaskEither<Failure, AuthUser?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return TaskEither.right(nextUser);
  }

  @override
  TaskEither<Failure, void> signInWithGoogle() => TaskEither.right(null);

  @override
  TaskEither<Failure, void> signOut() {
    current = null;
    return TaskEither.right(null);
  }

  Future<void> dispose() => _changes.close();
}
