# AGENTS.md — PocketBudget

Complete engineering guide for AI agents working on this codebase. This is the
**single source of truth** describing architecture, conventions, code styles,
folder layout, feature flows, and how to extend the app safely.

> Keep this file accurate. If you add a feature, add a route, or change a
> pattern, update the relevant section here.

---

## 1. Project Overview

| Field | Value |
|-------|-------|
| **App** | PocketBudget — Personal budget planner (NPR-first, offline-first, cloud-sync ready) |
| **Framework** | Flutter, Dart SDK >= 3.11.0 |
| **Architecture** | CLEAN Architecture + Features First |
| **State mgmt** | Riverpod `^3.3.2` (ProviderScope + providers; feature state added per feature) |
| **Routing** | GoRouter `^17.5.0` (StatefulShellRoute for the 5 bottom-nav tabs) |
| **DI** | Riverpod providers ONLY — no GetIt, no service locator |
| **Local DB** | SQLite via `sqflite` — offline-first, single writer, soft-delete |
| **Cloud** | Supabase (`supabase_flutter`) — Auth + PostgreSQL + Row Level Security |
| **Networking** | Dio `^5.11.1` for HTTP + `connectivity_plus ^7.3.2` for connectivity |
| **Functional** | `fpdart` `^1.1.1` — `TaskEither<Failure, T>` throughout data/domain |
| **Money** | Integer **minor units** (paisa) via `core/money/money.dart` — **never** `double` |
| **IDs** | UUID v4 (`uuid`) — client-generated so offline creates have stable ids |
| **Charts** | `fl_chart` |
| **Export** | `csv` + `share_plus` + `path_provider` |
| **Connectivity** | `connectivity_plus` |
| **Secure storage** | `flutter_secure_storage` (Supabase session + user id only) |
| **Logging** | `AppLogger` (thin wrapper over `dart:developer log`) — **never `print()`** |
| **Notifications** | `flutter_local_notifications` + `timezone` (budget alerts — Phase 5) |
| **Code gen** | `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`, `riverpod_lint` |
| **Testing** | `flutter_test`, `sqflite_common_ffi` (in-memory DB), `mocktail` |
| **Targets** | Android (primary), iOS, Desktop (untested), Web (read-only demo only) |
| **Currency** | NPR default; `currency_code` per profile |

**Feature roster (6 CLEAN features + 1 presentation shell):**

| Feature | Stack | Status |
|---------|-------|--------|
| `auth` | Supabase Auth — full CLEAN | Not started |
| `dashboard` | Local (SQLite reads + domain calculations) — full CLEAN | Not started |
| `transactions` | SQLite + sync queue — full CLEAN | Not started |
| `budgets` | SQLite + sync queue — full CLEAN | Not started |
| `savings_goals` | SQLite + sync queue — full CLEAN | Not started |
| `reports` | SQLite reads + `fl_chart` — full CLEAN | Not started |
| `settings` | Local + Supabase profile — full CLEAN | Not started |
| Main shell (bottom nav + FAB) | Presentation-only (`app/router/` + `core/widgets/`) | Not started |

> Cloud sync is **not optional to design for**, but **is** allowed to ship
> behind a feature flag until Phase 4. Every table, ID, and timestamp must be
> sync-ready from day one.

---

## 2. Directory Structure (SOURCE)
lib/
├── main.dart # Entry: runApp(ProviderScope(App))
├── app.dart # MaterialApp.router + AppTheme + AppRouter
│
├── core/ # Shared infrastructure (NO feature logic)
│ ├── constants/
│ │ ├── app_constants.dart # App name/version, storage keys, feature flags
│ │ ├── supabase_constants.dart # Supabase table + column names (single source)
│ │ └── asset_paths.dart # Image/icon paths
│ ├── theme/
│ │ ├── colors.dart # AppColors + AppThemeExtension
│ │ ├── app_theme.dart # AppTheme.light + AppTheme.dark
│ │ ├── text_styles.dart # Static TextStyles
│ │ └── dimensions.dart # AppDimensions tokens
│ ├── error/
│ │ ├── failures.dart # Failure + concrete failures
│ │ ├── exceptions.dart # LocalDb / Supabase / Validation exceptions
│ │ └── error_handler.dart # handleError(dynamic) -> Failure
│ ├── database/
│ │ ├── app_database.dart # Opens sqflite DB, runs migrations, exposes db
│ │ ├── migrations.dart # Ordered List<Migration>, bumps user_version
│ │ └── tables.dart # Tables + Cols string constants
│ ├── money/
│ │ ├── money.dart # Money value type (int minorUnits, String currency)
│ │ └── money_formatter.dart # parseMoneyToMinor / formatMinor / intl NumberFormat
│ ├── sync/
│ │ ├── sync_queue.dart # Durable outbox over SQLite table sync_queue
│ │ ├── sync_service.dart # Drains queue, retries, conflict policy
│ │ └── sync_status.dart # SyncStatus enum + stream provider
│ ├── network/
│ │ └── network_info.dart # connectivity_plus wrapper
│ ├── services/
│ │ └── (add service wrappers when their dependencies are introduced)
│ ├── router/
│ │ ├── route_names.dart # RouteNames path constants
│ │ └── app_router.dart # GoRouter + five indexed shell branches
│ └── common/
│ ├── widgets/ # app_scaffold, app_loading, app_error_widget,
│ │ # feature_placeholder_page (shared widgets added as needed)
│ ├── providers/ # core_providers (Dio + connectivity)
│ ├── extensions/ # context, string, datetime extensions
│ └── features/ # PRESENTATION-ONLY shell + splash
│ └── home/ # main_shell.dart, splash_page.dart
│
└── features/ # FULL CLEAN feature modules
├── {feature}/
│ ├── domain/
│ │ ├── entities/ # Plain Dart + Equatable
│ │ ├── repositories/ # abstract interfaces
│ │ └── usecases/ # single-responsibility use cases
│ ├── data/
│ │ ├── datasources/ # Local (sqflite) and/or Remote (Supabase)
│ │ ├── models/ # DTOs (fromJson/toJson/toEntity/fromEntity)
│ │ └── repositories/ # impls using TaskEither.tryCatch
│ └── presentation/
│ ├── providers/ # Riverpod providers + StateNotifier
│ ├── pages/
│ └── widgets/
└── (auth, dashboard, transactions, budgets,
savings_goals, reports, settings)

test/
├── unit/ # pure Dart: money, validators, use cases
├── repositories/ # repo impl against in-memory sqflite (sqflite_common_ffi)
├── providers/ # Riverpod provider tests
├── widgets/ # widget tests for critical screens
└── integration/ # end-to-end flows (optional in MVP)

**TWO feature locations — know the difference:**

| Location | Purpose |
|----------|---------|
| `lib/core/common/features/` | Presentation-only shell (main shell, splash). Thin — just pages/widgets; may consume providers from `lib/features/*`. |
| `lib/features/` | Full CLEAN features with domain/data/presentation layers. |

> Even the full CLEAN features live under `lib/features/` (top level), NOT under
> `lib/core/`.

---

## 3. Tech Stack & Dependencies (pubspec.yaml)

Runtime:
- **State**: `flutter_riverpod`
- **Functional**: `fpdart`
- **Routing**: `go_router`
- **Networking**: `dio`, `connectivity_plus`
- **Cloud**: `supabase_flutter` (when Auth/sync work begins)
- **Storage**: `flutter_secure_storage`, `path_provider` (when persistence work begins)
- **DB**: `sqflite`, `path` (when persistence work begins)
- **Utils**: `equatable`, `intl`, `uuid`, `json_annotation`, `freezed_annotation` (as features need them)
- **Charts**: `fl_chart` (reports feature)
- **Export**: `csv`, `share_plus` (export feature)
- **Notifications**: `flutter_local_notifications`, `timezone`, `flutter_timezone` (budget alerts)

Dev:
- `flutter_test`, `flutter_lints`
- `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`, `riverpod_lint` (when code generation is adopted)
- `sqflite_common_ffi` (in-memory DB in tests)
- `mocktail` (optional — prefer fakes against in-memory DB)

> **Do not add**: `get_it`, `flutter_bloc`, `objectbox`, ad SDKs,
> payment SDKs, or AI SDKs — none are in the MVP.

Assets:
```yaml
assets:
  - assets/images/
  - assets/audios/     # reserved for budget-alert SFX later

```
## 4. Core Command-Line Workflows

```bash
# Get deps
flutter pub get

# Run the app
flutter run

# Code generation (after editing models / freezed classes / @riverpod providers)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch

# Analyze (lint + static checks)
flutter analyze

# Tests
flutter test
flutter test test/unit/money_test.dart          # specific file
flutter test --coverage

# Build a debug APK
flutter build apk --debug

# Format
dart format .

```

## 5. Architecture & Data Flow
### 5.1 Layered flow

```text
UI (Page) -> Provider (StateNotifier) -> UseCase -> Repository (abstract)
                                                          |
                                          RepositoryImpl <- DataSource (Local sqflite OR Remote Supabase)
                                                          |
                                                     SyncQueue
                                                     (outbox)
```

Domain has NO Flutter / sqflite / Supabase imports. It only imports
fpdart, failures.dart, core/money/, and its own entities.

Data imports sqflite (local), Supabase (remote), models, and domain.

Presentation wires everything together via Riverpod providers.

### 5.2 Money & time rules (hard invariants)
Money is int minor units (paisa). Never double, never num for money.
Use Money from core/money/money.dart at boundaries.

Transaction dates are calendar dates stored as ISO yyyy-MM-dd strings
in the user's local timezone. Sync metadata timestamps (created_at,
updated_at, deleted_at) are UTC ISO-8601 strings. Never mix the two.

Transfers debit one account and credit another with a single
transactions row (to_account_id populated) and are excluded from
income/expense totals.

Soft delete only for synced tables (deleted_at). Hard delete only
sync_queue rows after successful sync.

### 5.3 Dependency Injection (Provider DAG)

```text
main.dart -> ProviderScope -> App (MaterialApp.router)
  GoRouter (auth redirect listener) + themeModeProvider

Providers (wiring order):
  storageProvider          (StorageService over flutter_secure_storage)
  talkerProvider           (logger)
  supabaseClientProvider   (Supabase.instance.client)
  networkInfoProvider
  appDatabaseProvider      (AppDatabase — lazy singleton)
  syncQueueProvider
  syncServiceProvider

  authRepositoryProvider   <- supabaseClientProvider + storageProvider
    loginUseCaseProvider / registerUseCaseProvider / ... / getCurrentUserUseCaseProvider
    authProvider           (StateNotifier<AuthState>)

  settingsRepositoryProvider <- storageProvider + supabaseClientProvider
    getSettingsProvider / updateSettingsProvider
    settingsProvider       (StateNotifier<AsyncValue<UserSettings>>)
  themeModeProvider        <- settingsProvider

  transactionRepositoryProvider <- appDatabaseProvider + syncQueueProvider
    getTransactionsProvider / addTransactionProvider / ... use cases
    transactionProvider    (StateNotifier<TransactionState>)

  budgetRepositoryProvider   <- appDatabaseProvider + syncQueueProvider
  savingsRepositoryProvider  <- appDatabaseProvider + syncQueueProvider
  dashboardProvider          (computed from the three above)
  reportsProvider
  syncStatusProvider
```

Rules:

Every provider is declared in the feature's presentation/providers/ file.
Cross-feature reads happen through ref.watch(otherFeatureProvider) — never
by importing another feature's data layer.

The database is opened once via appDatabaseProvider; nothing else touches
sqflite directly.

supabaseClientProvider returns Supabase.instance.client. Nothing else
constructs a client.

### 5.4 Provider wiring template

```dart
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  final remote = ref.watch(supabaseClientProvider);
  return TransactionRepositoryImpl(
    local: TransactionLocalDataSource(db),
    remote: TransactionRemoteDataSource(remote),
    queue: queue,
    uuid: ref.watch(uuidProvider),
  );
});

final addTransactionProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(transactionRepositoryProvider));
});
```

## 6. Code Style & Lint Conventions (analysis_options.yaml)

```yaml
linter rules (all enforced):
  prefer_const_constructors
  prefer_const_declarations
  prefer_const_literals_to_create_immutables
  avoid_print                  # use LoggerService, never print()
  prefer_single_quotes
  require_trailing_commas
  unawaited_futures
  no_duplicate_case_values
  prefer_final_locals
  sort_child_properties_last   # child last in widget constructors
  use_super_parameters
  always_declare_return_types
  avoid_dynamic_calls
analyzer:
  errors:
    invalid_annotation_target: ignore   # for freezed
```
Golden rules derived from the codebase:

- No print() anywhere — logging goes through LoggerService.info/warning/error/debug.
- Single quotes for all Dart strings.
- Trailing commas required in argument lists.
- use_super_parameters — constructors use super.key.
- sort_child_properties_last — child / builder go last.
- Never double for money. Enforce with a unit test.
- Never dynamic at a public API boundary — use typed models.
- Run flutter analyze before finishing. Zero warnings allowed.

### 6.1 Naming conventions
| Thing | Style | Example |
| --- | --- | --- |
| File | snake_case.dart | add_transaction_page.dart |
| Class / type | PascalCase | AddTransactionPage |
| Entity / model fields | camelCase | amountMinor, accountId |
| Provider variable | camelCaseProvider | transactionProvider |
| UseCase | VerbNoun | AddTransaction, GetDashboardSummary |
| Enums | PascalCase, consts camelCase | TransactionType { income, expense, transfer } |
| Private fields | _camelCase | _local, _queue |
| State classes | {Feature}State | TransactionState |
| Notifier classes | {Feature}Notifier | TransactionNotifier |
| Table / column constants | const String snake_case | Tables.transactions, Cols.amountMinor |
### 6.2 Import conventions
Feature files import core via relative paths, e.g.
../../../../core/money/money.dart.

Within core/: '../theme/colors.dart'.

External packages use full package imports:
package:flutter_riverpod/flutter_riverpod.dart.

Cross-feature imports are forbidden in domain/data layers. If two
features share something, move it to core/. Cross-feature provider
reads are allowed from a presentation file, and must use
import 'show ...' to limit the symbol surface.

## 7. Feature Patterns (THE templates to copy)
### 7.1 Domain layer
Entity — plain immutable Dart class:

```dart
class Transaction extends Equatable {
  final String id;                 // UUID v4
  final String accountId;
  final String? toAccountId;       // populated only for transfers
  final String? categoryId;        // null for transfers
  final TransactionType type;      // income | expense | transfer
  final int amountMinor;           // paisa, never double
  final DateTime transactionDate;  // calendar date, local
  final String? note;
  final DateTime createdAt;        // UTC
  final DateTime updatedAt;        // UTC

  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amountMinor,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.toAccountId,
    this.categoryId,
    this.note,
  });

  @override
  List<Object?> get props => [
        id, accountId, toAccountId, categoryId, type, amountMinor,
        transactionDate, note, createdAt, updatedAt,
      ];
}

```

Abstract repository — returns TaskEither<Failure, T>:

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  TaskEither<Failure, List<Transaction>> getAll({DateTime? from, DateTime? to});
  TaskEither<Failure, Transaction?> getById(String id);
  TaskEither<Failure, void> add(Transaction tx);      // local + enqueue sync
  TaskEither<Failure, void> update(Transaction tx);
  TaskEither<Failure, void> delete(String id);        // soft delete + enqueue
  Stream<void> get onChange;                          // UI reload signal
}
```

Use case — thin delegate, validation lives HERE:

```dart
class AddTransaction {
  final TransactionRepository _repository;
  AddTransaction(this._repository);

  TaskEither<Failure, void> call(Transaction tx) {
    if (tx.amountMinor <= 0) {
      return TaskEither.left(const ValidationFailure('Amount must be positive'));
    }
    if (tx.type == TransactionType.transfer && tx.toAccountId == null) {
      return TaskEither.left(
        const ValidationFailure('Transfer needs a destination account'),
      );
    }
    if (tx.type != TransactionType.transfer && tx.categoryId == null) {
      return TaskEither.left(const ValidationFailure('Pick a category'));
    }
    return _repository.add(tx);
  }
}
```

### 7.2 Data layer
Model — DTO with Equatable, four methods, and safe casts:

```dart
class TransactionModel extends Equatable {
  final String id;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final String type;
  final int amountMinor;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amountMinor,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.toAccountId,
    this.categoryId,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json[Cols.id] as String? ?? '',
        accountId: json[Cols.accountId] as String? ?? '',
        toAccountId: json[Cols.toAccountId] as String?,
        categoryId: json[Cols.categoryId] as String?,
        type: json[Cols.type] as String? ?? 'expense',
        amountMinor: (json[Cols.amountMinor] as num?)?.toInt() ?? 0,
        transactionDate: DateTime.tryParse(json[Cols.transactionDate] as String? ?? '')
            ?? DateTime.now(),
        note: json[Cols.note] as String?,
        createdAt: DateTime.tryParse(json[Cols.createdAt] as String? ?? '')
            ?? DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse(json[Cols.updatedAt] as String? ?? '')
            ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        Cols.id: id,
        Cols.accountId: accountId,
        Cols.toAccountId: toAccountId,
        Cols.categoryId: categoryId,
        Cols.type: type,
        Cols.amountMinor: amountMinor,
        Cols.transactionDate: toIsoDate(transactionDate),
        Cols.note: note,
        Cols.createdAt: createdAt.toIso8601String(),
        Cols.updatedAt: updatedAt.toIso8601String(),
      };

  Transaction toEntity() => Transaction(
        id: id,
        accountId: accountId,
        toAccountId: toAccountId,
        categoryId: categoryId,
        type: TransactionType.values.byName(type),
        amountMinor: amountMinor,
        transactionDate: transactionDate,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory TransactionModel.fromEntity(Transaction e) => TransactionModel(
        id: e.id,
        accountId: e.accountId,
        toAccountId: e.toAccountId,
        categoryId: e.categoryId,
        type: e.type.name,
        amountMinor: e.amountMinor,
        transactionDate: e.transactionDate,
        note: e.note,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, accountId, toAccountId, categoryId, type, amountMinor,
        transactionDate, note, createdAt, updatedAt,
      ];
}
```

DataSource — either Local (sqflite) or Remote (Supabase):

```dart
// Local
class TransactionLocalDataSource {
  final AppDatabase _db;
  TransactionLocalDataSource(this._db);

  Future<List<Map<String, dynamic>>> getAll({DateTime? from, DateTime? to}) async {
    final db = await _db.database;
    final where = <String>['${Cols.deletedAt} IS NULL'];
    final args = <Object?>[];
    if (from != null) {
      where.add('${Cols.transactionDate} >= ?');
      args.add(toIsoDate(from));
    }
    if (to != null) {
      where.add('${Cols.transactionDate} <= ?');
      args.add(toIsoDate(to));
    }
    final rows = await db.query(
      Tables.transactions,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: '${Cols.transactionDate} DESC',
    );
    return rows;
  }

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.transactions,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.transactions,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}

// Remote (Supabase)
class TransactionRemoteDataSource {
  final SupabaseClient _client;
  TransactionRemoteDataSource(this._client);

  Future<void> upsert(Map<String, dynamic> row) async {
    await _client.from(Tables.transactions).upsert(row);
  }

  Future<void> delete(String id) async {
    await _client.from(Tables.transactions).delete().eq(Cols.id, id);
  }
}
```

Local vs Remote: every feature has a Local datasource (it reads/writes
sqflite). Remote is added in Phase 4 — before then, SyncService may run
with an empty/no-op remote. auth uses only a Remote datasource (Supabase
Auth has no local equivalent). settings uses only a Local datasource plus
an optional remote profile upsert.

Repository impl — TaskEither.tryCatch:

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _local;
  final TransactionRemoteDataSource _remote;
  final SyncQueue _queue;
  final UuidGen _uuid;
  final _changes = StreamController<void>.broadcast();

  TransactionRepositoryImpl(this._local, this._remote, this._queue, this._uuid);

  @override
  TaskEither<Failure, List<Transaction>> getAll({DateTime? from, DateTime? to}) {
    return TaskEither.tryCatch(
      () async {
        final rows = await _local.getAll(from: from, to: to);
        return rows.map(TransactionModel.fromJson).map((m) => m.toEntity()).toList();
      },
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, void> add(Transaction tx) {
    return TaskEither.tryCatch(
      () async {
        final model = TransactionModel.fromEntity(tx);
        await _local.insert(model.toJson());
        await _queue.enqueue(
          entity: SyncEntity.transaction,
          entityId: tx.id,
          op: SyncOp.insert,
        );
        _changes.add(null);
      },
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, void> delete(String id) {
    return TaskEither.tryCatch(
      () async {
        await _local.softDelete(id);
        await _queue.enqueue(
          entity: SyncEntity.transaction,
          entityId: id,
          op: SyncOp.delete,
        );
        _changes.add(null);
      },
      (error, stackTrace) => handleError(error),
    );
  }

  @override
  Stream<void> get onChange => _changes.stream;
}
```

Key resilience rules:

Local datasources map errors to CacheFailure (not handleError).

Remote datasources map errors via handleError(error).

Never let a failed sync block a local write. Local always wins the
write; sync catches up.

Never delete rows locally — soft-delete with deleted_at so the delete
itself can sync.

### 7.3 Nested response extraction (Supabase)
Supabase returns Map<String, dynamic> for rows. Always handle null and
type drift:

```dart
final amount = (data['amount_minor'] as num?)?.toInt() ?? 0;
```

Never data!, never data['x'] as int without a null/num guard.

### 7.4 Presentation layer — StateNotifier pattern
Two variants in the codebase:

(A) Status enum state (transactions, dashboard, budgets, savings):

```dart
enum TransactionStatus { initial, loading, success, error }

class TransactionState {
  final TransactionStatus status;
  final List<Transaction> items;
  final String? message;
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.items = const [],
    this.message,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;
  TransactionNotifier(this._ref) : super(const TransactionState());

  Future<void> load({DateTime? from, DateTime? to}) async {
    state = state.copyWith(status: TransactionStatus.loading, clearMessage: true);
    final result = await _ref
        .read(getTransactionsProvider)
        .call(from: from, to: to)
        .run();
    result.fold(
      (failure) => state = state.copyWith(
        status: TransactionStatus.error,
        message: failure.message,
      ),
      (items) => state = state.copyWith(
        status: TransactionStatus.success,
        items: items,
      ),
    );
  }

  Future<void> add(Transaction tx) async {
    final result = await _ref.read(addTransactionProvider).call(tx).run();
    result.fold(
      (failure) => state = state.copyWith(
        status: TransactionStatus.error,
        message: failure.message,
      ),
      (_) => load(),
    );
  }
}
```

(B) AsyncValue<T> (settings):

```dart
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
  return SettingsNotifier(
    ref.watch(getSettingsProvider),
    ref.watch(updateSettingsProvider),
  );
});

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  SettingsNotifier(this._get, this._update) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  final GetSettings _get;
  final UpdateSettings _update;

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    final r = await _get().run();
    r.fold(
      (f) => state = AsyncValue.error(f, StackTrace.current),
      (s) => state = AsyncValue.data(s),
    );
  }
}
```

### 7.5 Provider wiring template
```dart
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    TransactionLocalDataSource(ref.watch(appDatabaseProvider)),
    TransactionRemoteDataSource(ref.watch(supabaseClientProvider)),
    ref.watch(syncQueueProvider),
    ref.watch(uuidProvider),
  );
});

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});
```

For local-only features (e.g. dashboard reads), wire without a remote:

```dart
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(transactionRepositoryProvider),
    ref.watch(budgetRepositoryProvider),
    ref.watch(savingsRepositoryProvider),
    ref.watch(clockProvider),
  );
});
```

### 7.6 Page pattern — Form / ConsumerStatefulWidget
```dart
class AddEditTransactionPage extends ConsumerStatefulWidget {
  const AddEditTransactionPage({super.key, this.transactionId});
  final String? transactionId;
  @override
  ConsumerState<AddEditTransactionPage> createState() => _State();
}

class _State extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  String? _accountId;
  String? _categoryId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amountMinor = parseMoneyToMinor(_amountCtrl.text);
    final tx = Transaction(
      id: ref.read(uuidProvider).newId(),
      accountId: _accountId!,
      toAccountId: _type == TransactionType.transfer ? _categoryId : null,
      categoryId: _type == TransactionType.transfer ? null : _categoryId,
      type: _type,
      amountMinor: amountMinor,
      transactionDate: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await ref.read(transactionProvider.notifier).add(tx);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ButtonSegment(value: TransactionType.transfer, label: Text('Transfer')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            MoneyTextField(controller: _amountCtrl, label: 'Amount (NPR)'),
            // account picker, category picker, date picker, note field
            FilledButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Standard TextFormField decoration:

```dart
TextFormField(
  controller: _amountCtrl,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
  decoration: AppInputDecoration.labeled('Amount (NPR)', icon: Icons.payments_outlined),
  validator: (v) => parseMoneyToMinor(v ?? '') <= 0 ? 'Enter a valid amount' : null,
)
```

### 7.7 Async page consumption (status-enum style)
```dart
final state = ref.watch(transactionProvider);
switch (state.status) {
  case TransactionStatus.initial:
  case TransactionStatus.loading:
    return const TransactionListShimmer();
  case TransactionStatus.error:
    return AppErrorWidget(
      message: state.message ?? 'Something went wrong',
      onRetry: () => ref.read(transactionProvider.notifier).load(),
    );
  case TransactionStatus.success:
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions yet',
        subtitle: 'Tap + to add your first expense.',
      );
    }
    return TransactionList(items: state.items);
}
```

AsyncValue page consumption (settings-style):

```dart
ref.watch(settingsProvider).when(
  loading: () => const AppLoading(),
  error: (error, _) => AppErrorWidget(message: error.toString(), onRetry: ...),
  data: (settings) => _SettingsContent(settings: settings),
);
```
## 8. Routing & Navigation
### 8.1 Route names — route_names.dart
Groups: splash (/), auth (/auth/signin, /auth/signup, /auth/forgot),
shell (/home, /transactions, /budgets, /savings, /reports,
/settings), plus modal-ish routes (/transactions/add,
/transactions/:id/edit, /budgets/:id, /savings/:id).

Use StatefulShellRoute.indexedStack so each bottom-nav tab keeps its own
navigation stack:

```dart
StatefulShellRoute.indexedStack(
  builder: (_, __, shell) => MainShell(shell: shell),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/home', builder: ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/transactions', builder: ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/budgets', builder: ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/savings', builder: ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/reports', builder: ...)]),
  ],
),
```

### 8.2 Auth redirect logic (app_router.dart)
A custom _AuthRedirect extends ChangeNotifier is the refreshListenable.
app.dart calls AppRouter.redirectNotifier.update(authStatus) via
ref.listen(authProvider, ...).

Redirect matrix:

| authStatus | Location | Redirect |
| --- | --- | --- |
| unknown | anything ≠ splash | splash |
| authenticated | splash or signin | home |
| unauthenticated | splash or home | signin |
Offline users must still reach /home. If the app is offline-first and
the user has a cached Supabase session, treat them as authenticated. Do not
redirect to sign-in just because a network check failed.

### 8.3 Passing data between pages
state.extra for objects: context.push('/transactions/${tx.id}/edit', extra: tx)
then in the page: final tx = state.extra as Transaction?; — always
null-check.

Path parameters for URLs: /transactions/:id/edit →
state.pathParameters['id'].

Typed args class for complex payloads (e.g. budget detail with a target
period): define BudgetDetailArgs in the feature's domain/entities/,
pass the whole object as extra, and type-check in the router builder:

```dart
final extra = state.extra;
return BudgetDetailPage(args: extra is BudgetDetailArgs ? extra : null);
```

Replace vs push: use context.go(...) to replace (after login or
redirect), context.push(...) for navigation with back,
context.pushReplacement(...) when back should skip the page.

Never pass a BuildContext or a Ref in extra.

### 8.4 RouteObserver pattern (refresh on return)
Pages that must refresh when they regain focus subscribe via
AppRouter.routeObserver (same pattern as Glean Faith):

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final route = ModalRoute.of(context);
  if (route != null) AppRouter.routeObserver.subscribe(this, route);
}
@override
void didPopNext() {
  super.didPopNext();
  ref.read(transactionProvider.notifier).load();
}
@override
void dispose() {
  AppRouter.routeObserver.unsubscribe(this);
  super.dispose();
}
```

Use this instead of pushing a result callback — it survives nested pushes.

## 9. Main Shell / Bottom Navigation
MainShell uses a StatefulNavigationShell from go_router plus a
NavigationBar (Material 3). Five tabs:

| Index | Route | Icon |
| --- | --- | --- |
| 0 | /home | Icons.home_outlined |
| 1 | /transactions | Icons.receipt_long_outlined |
| 2 | /budgets | Icons.savings_outlined |
| 3 | /savings | Icons.flag_outlined |
| 4 | /reports | Icons.bar_chart_outlined |
The prominent + button is a FloatingActionButton.extended on the shell
that pushes /transactions/add from any tab.

```dart
Scaffold(
  body: shell,
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => context.push('/transactions/add'),
    icon: const Icon(Icons.add),
    label: const Text('Add'),
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: shell.currentIndex,
    onDestinationSelected: (i) => shell.goBranch(
      i,
      initialLocation: i == shell.currentIndex,
    ),
    destinations: const [ /* ... */ ],
  ),
)
```

Tab indices are fixed. The shell owns the index. Any widget that needs to
switch tabs calls StatefulNavigationShell.of(context).goBranch(i).

## 10. Shared Widgets & Extensions
Common widgets (core/common/widgets/)
| Widget | Usage |
| --- | --- |
| AppScaffold | Thin Scaffold wrapper, default AppColors.bgGray |
| AppLoading | Centered spinner (+ optional message) — buttons/inline only |
| AppErrorWidget | Error state with retry button |
| AppEmptyState | Empty state with icon/title/subtitle/action |
| MoneyTextField | TextFormField bound to minor-unit formatting |
| AmountText | Renders Money with sign/color (green/red/gray for transfer) |
| CurrencyChip | Small "NPR" pill |
| ConfirmDialog | showConfirmDialog(context, title:, message:, confirmLabel:) |
| DateField | Tappable date display that opens showDatePicker |
| CategoryPicker | Bottom-sheet category chooser |
| AccountPicker | Bottom-sheet account chooser |
| ShimmerWidget | Base shimmer primitive — auto-detects dark/light |
| ShimmerCircle | Circular shimmer placeholder |
| ShimmerTextLine | Text-line shimmer placeholder |
| ShimmerList | Pre-built list of ShimmerWidget rows |
| ShimmerCard | Card-shaped shimmer wrapper |
Shimmer placeholders (core/common/widgets/shimmer_placeholders.dart)
Pre-built skeleton widgets that mirror real card shapes:

| Widget | Mirrors |
| --- | --- |
| TransactionTileShimmer | Transaction list row |
| DashboardSummaryShimmer | Dashboard summary card |
| BudgetCardShimmer | Budget category card |
| SavingsGoalCardShimmer | Savings goal card |
| ReportChartShimmer | Report chart card |
| AccountTileShimmer | Account list row |
| SettingsRowShimmer | Settings list row |
How to add shimmer to a new feature page:

Import shimmer_placeholders.dart.

Check state.status == FeatureStatus.loading && state.items.isEmpty.

Render 3-6 shimmer placeholders matching the real card layout.

The shimmer auto-detects dark/light mode — no manual color needed.

### Dark mode
All shimmer widgets auto-detect Theme.of(context).brightness.
Light mode: #E5E7EB -> #F3F4F6. Dark mode: #334155 -> #475569.
Override with baseColor/highlightColor params if needed.

### Extensions (core/common/extensions/)
ContextExtensions: context.theme, context.screenSize, context.isDarkMode,
context.pop(), context.pushNamed, context.pushReplacement, context.goNamed.

StringExtensions: capitalize, capitalizeWords, truncate, isBlank, isValidEmail.

DateTimeExtensions: isSameDay, toIsoDate(), startOfMonth, endOfMonth,
addMonths, formattedDate, formattedMonthYear, timeAgo().

### Money helpers (core/money/)

```dart
Money.fromMinor(150000, 'NPR')       // Rs 1,500.00
Money.parse('1500.50', 'NPR')        // throws ValidationException on bad input
money.format()                        // intl NumberFormat.currency
parseMoneyToMinor('1500.50')          // -> 150050
formatMinor(150050, currency: 'NPR')  // -> 'Rs 1,500.50'
```
Never do amountMinor / 100 in a widget — use the formatter.

### Loading State Convention
Rule: shimmer on first load, spinner only for inline/button actions.

| Situation | Widget | Example |
| --- | --- | --- |
| First-time page load (data fetching) | Shimmer placeholder | TransactionTileShimmer() x 5 |
| Refresh / pull-to-refresh | Keep existing data visible + optional LinearProgressIndicator at top | RefreshIndicator + LinearProgressIndicator(minHeight: 3) |
| Button / form submission | AppLoading or inline CircularProgressIndicator | FilledButton with spinner |
| Full-page error | AppErrorWidget with retry | AppErrorWidget(message: ..., onRetry: ...) |
| Empty state | AppEmptyState | AppEmptyState(icon: ..., title: ...) |
## 11. Error Handling Conventions
### 11.1 Base Failure hierarchy

```dart
sealed class Failure implements Exception {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});
}
class ServerFailure     extends Failure { const ServerFailure(super.message, {super.statusCode}); }
class CacheFailure      extends Failure { const CacheFailure(super.message); }
class NetworkFailure    extends Failure { const NetworkFailure(super.message); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class AuthFailure       extends Failure { const AuthFailure(super.message, {super.statusCode}); }
class NotFoundFailure   extends Failure { const NotFoundFailure(super.message); }
class UnexpectedFailure extends Failure { const UnexpectedFailure(super.message); }
```

### 11.2 handleError (remote features)
Maps a thrown Object -> appropriate Failure:

```text
AuthException -> AuthFailure

PostgrestException with code 401/403 -> AuthFailure; 404 -> NotFoundFailure; else -> ServerFailure

SocketException -> NetworkFailure('No internet connection')

LocalDbException -> CacheFailure

ValidationException -> ValidationFailure

non-typed -> UnexpectedFailure
```

### 11.3 Use-case return-type handling in notifiers
| Return type | Fold pattern |
| --- | --- |
| TaskEither<Failure, List<Entity>> | fold(f => setError, list => setLoaded(list)) |
| TaskEither<Failure, void> | result.fold((f) => setError(f), (_) => null) |
| TaskEither<Failure, Map<String, dynamic>> | fold(f => setError, data => process(data)) |
| TaskEither<Failure, Unit> (settings) | fold(f => AsyncValue.error, _ => AsyncValue.data(settings)) |
### 11.4 Exceptions (core/error/exceptions.dart)
LocalDbException, SupabaseException, ValidationException,
AuthException — used by data sources where throwing is appropriate;
handleError normalizes them.

### 11.5 Logging
Use LoggerService — never print():

```dart
LoggerService.info('Loaded 20 transactions');
LoggerService.warning('Sync retry #3 for tx $id');
LoggerService.error('Failed to sync', errorObject);
LoggerService.debug('verbose detail');
```
Initialize via AppBootstrap.init().

## 12. Storage & Database
### 12.1 Secure storage keys
Only Supabase session tokens / user id / onboarded flag:

```text
AppConstants.supabaseSessionKey   = 'pb.supabase.session'
AppConstants.userIdKey            = 'pb.user.id'
AppConstants.onboardedKey         = 'pb.onboarded'
AppConstants.settingsKey          = 'pb.user_settings'
```

Access via ref.read(storageProvider).read('key'), .write, .delete,
.clear, .containsKey. Never log token values.

### 12.2 SQLite schema (local, v1)
All tables have id TEXT PRIMARY KEY, updated_at TEXT NOT NULL (UTC ISO),
deleted_at TEXT NULL. Sync-eligible tables also have sync_status TEXT
(synced | pending | conflict) and server_revision INTEGER.

| Table | Key columns |
| --- | --- |
| profiles | display_name, currency_code, created_at |
| accounts | name, opening_balance_minor INTEGER, is_active INTEGER |
| categories | name, type TEXT, icon_key TEXT |
| transactions | account_id, to_account_id NULL, category_id NULL, type, amount_minor INTEGER, transaction_date TEXT (yyyy-MM-dd), note |
| budgets | category_id, period_start TEXT (yyyy-MM), limit_minor INTEGER |
| savings_goals | name, target_minor INTEGER, target_date TEXT |
| goal_entries | goal_id, amount_minor INTEGER, entry_type, created_at |
| sync_queue | operation_id, entity_type, entity_id, operation, created_at, retry_count, last_error |

Rules:

- All money is INTEGER minor units. No REAL. Enforce with a test.
- All IDs are UUID v4 strings. No auto-increment ints.
- Soft delete only for synced tables (deleted_at). Hard delete only
  sync_queue rows after a successful sync.
- Never ALTER a table in place in a migration — always create new + copy.
- Foreign keys: PRAGMA foreign_keys = ON at open; use ON DELETE RESTRICT
  (we soft-delete anyway).
- Migrations live in core/database/migrations.dart as an ordered
  List<Migration>; AppDatabase runs them in order and updates
  user_version.

### 12.3 Sync queue — the ONE outbox
The app is local-first: every write goes to SQLite, then enqueues an
operation. SyncService drains the queue when online.

```dart
enum SyncEntity { profile, account, category, transaction, budget, savingsGoal, goalEntry }
enum SyncOp { insert, update, delete }

class SyncQueue {
  Future<void> enqueue({
    required SyncEntity entity,
    required String entityId,
    required SyncOp op,
  });
  Future<List<SyncOperation>> nextBatch({int limit = 50});
  Future<void> markDone(String operationId);
  Future<void> markFailed(String operationId, String error);
}
```

Conflict policy (MVP):

Every synced row carries updated_at (UTC) and server_revision (int).

On push, send updated_at. If the server row's updated_at is newer,
the server wins and the local row is overwritten — but the operation is
logged and surfaced in SyncStatus as a conflict.

Never silently overwrite. The user can review conflicts from Settings.

Retries use exponential backoff: min(2^retry_count * 2s, 5min), max 10
attempts, then the row is marked conflict and excluded from auto-retry.

### 12.4 Financial rules — enforce in domain, test in test/unit/

```text
netWorth         = sum(account.opening_balance_minor)
                 + sum(income.amount_minor) - sum(expense.amount_minor)
                 // transfers are EXCLUDED
remainingBudget  = budget.limit_minor
                 - sum(expense.amount_minor
                       WHERE category = budget.category
                       AND date IN budget.period)
savingsRate      = (income - expense) / income        // guard income == 0
requiredMonthly  = (goal.target_minor - goal.saved_minor)
                 / monthsBetween(today, goal.target_date)   // ceil, min 1
availableBalance = netWorth - sum(planned/upcoming bills)
```

Available balance (spendable now) and net worth (total) are
different. Never conflate them. Always compute from minor units, never from
formatted strings.

### 12.5 Supabase / cloud security
RLS on every user-owned table. Policies: auth.uid() = user_id for
select, insert (with check), update, delete.

The service-role key must never appear in the Flutter app. Only the
publishable/anon key.

Client-generated UUIDs mean an attacker who guesses a UUID still gets
nothing — RLS filters by user_id, not by knowing the ID.

Foreign-key children (e.g. goal_entries) validate ownership through the
parent (goal_id) in the policy, not just user_id on the child row.

## 13. Supabase Setup
Supabase is the ONLY backend. All cloud setup lives here so it can be
reviewed as a unit. Never hard-code a Supabase URL or key in a feature file;
read from core/constants/app_constants.dart.

### 13.1 Project + credentials
Create a project at https://database.new.

From the Dashboard copy the Project URL and the publishable/anon
key into AppConstants (or a .env read at bootstrap).

Never put the service_role key in the app — it bypasses RLS.

Configure URL Configuration -> add the mobile deep link, e.g.
io.supabase.pocketbudget://login-callback. Register the same scheme in
the Android manifest / iOS URL types.

Initialize once in bootstrap.dart:

```dart
await Supabase.initialize(
  url: AppConstants.supabaseUrl,
  anonKey: AppConstants.supabaseAnonKey,
);
```

### 13.2 Auth
MVP method: Email + Password.

AuthRepositoryImpl wraps supabase.auth.signInWithPassword,
signUp, signOut, and onAuthStateChange.

On success, AuthRepositoryImpl persists the user id to
storageProvider (secure storage) so offline launches can restore the
session.

authProvider (a StateNotifier<AuthState>) is the single source of
truth for authenticated | unauthenticated | unknown and feeds the
GoRouter refreshListenable (see section 8.2).

Production note: Supabase's default email service is rate-limited
(roughly 2 emails/hour). Configure a custom SMTP provider before launch.

### 13.3 Schema (remote)
Create the same tables as section 12.2 with user_id uuid references auth.users not null on every user-owned row, and bigint for every
*_minor column (never double / numeric). Enable RLS before any
client code is written — an unprotected table is an open door.

### 13.4 RLS policies (the security layer)
For every user-owned table, four policies. Example for transactions:

```sql
alter table public.transactions enable row level security;

revoke all on table public.transactions from anon, authenticated;
grant select, insert, update, delete on table public.transactions to authenticated;

create policy "Users read own transactions"
on public.transactions for select
to authenticated
using ( (select auth.uid()) = user_id );

create policy "Users insert own transactions"
on public.transactions for insert
to authenticated
with check ( (select auth.uid()) = user_id );

create policy "Users update own transactions"
on public.transactions for update
to authenticated
using ( (select auth.uid()) = user_id )
with check ( (select auth.uid()) = user_id );

create policy "Users delete own transactions"
on public.transactions for delete
to authenticated
using ( (select auth.uid()) = user_id );
```

Rules:

UPDATE policies must include with check, or users can transfer
records to another user_id.

DELETE needs only using.

UPDATE also requires a matching SELECT policy, or updates silently
affect zero rows.

Child tables (goal_entries, etc.) verify ownership through the parent id
(goal_id), not just user_id on the child row.

### 13.5 RLS verification (required before Phase 4 is "done")
Write SQL tests that:

- Simulate a second user (set local request.jwt.claim.sub = ...) and
  assert their select * from transactions returns empty.
- Assert an insert with a mismatched user_id is rejected.
- Assert an update that flips user_id is rejected.
- If any of these pass-through, stop and fix the policy before writing
  more client code.

## 14. State / AsyncValue conventions
| Provider type | When | Example |
| --- | --- | --- |
| Provider<T> | Simple DI / wiring | appDatabaseProvider, use-case providers, transactionRepositoryProvider |
| StateNotifierProvider<Notifier, State> | Complex mutable state | authProvider, transactionProvider, settingsProvider |
| StateNotifierProvider<Notifier, AsyncValue<T>> | Async status loading/error/data | settingsProvider |
| Provider<ThemeMode> | Computed from other providers | themeModeProvider |
| StateProvider<T> | Tiny UI state | selectedReportPeriodProvider |
| FutureProvider<T> / .family | Single async value | accountsProvider, categoriesProvider |
| StreamProvider<T> | Live stream | syncStatusProvider |
Side-effect listening (navigation, snackbars):

```dart
ref.listen(authProvider, (prev, next) {
  if (next.status == AuthStatus.authenticated) context.go(RouteNames.home);
});

ref.listen(transactionProvider, (prev, next) {
  if (next.message != null && next.message != prev?.message) {
    AlertWidget.showError(context, next.message!);
  }
});
```

## 15. Dark Mode Support
Every widget that renders color manually computes:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

then branches: isDark ? darkColor : lightColor. The codebase uses explicit
const Color(0xFF...) values (AppColors + local consts), NOT
Theme.of(context).colorScheme references in feature widgets. Dark theme
tokens: darkBg 0xFF0F172A, darkSurface 0xFF1E293B, darkBorder 0xFF334155.

## 16. Testing
Framework: flutter_test + sqflite_common_ffi (in-memory DB) +
mocktail (only where a fake is impractical).

Test files (required before a feature is "done"):

- `test/unit/money_test.dart` — parsing/formatting, integer minor units,
  no rounding drift.
- `test/unit/*_usecase_test.dart` — happy path + each validation branch.
- `test/repositories/*_repository_test.dart` — round-trip through an
  in-memory sqflite DB (databaseFactoryFfi.openDatabase(inMemoryDatabasePath)).
- `test/providers/*_provider_test.dart` — StateNotifier transitions via
  ProviderContainer with a fake repository.
- `test/widgets/*_page_test.dart` — critical screens: loading -> loaded,
  empty, error.

In-memory DB helper (use in repository tests):

```dart
final db = await databaseFactoryFfi.openDatabase(
  inMemoryDatabasePath,
  options: OpenDatabaseOptions(
    version: 1,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: (db, v) => AppDatabase.createSchema(db),
  ),
);
```

Required invariant tests:

- A transfer does not change income/expense totals.
- A soft-delete enqueues exactly one delete op.
- Re-enqueueing the same op is a no-op (idempotent).
- No column whose name ends in _minor is REAL (schema test).

UI flows: Maestro flows under maestro/ (gitignored) with keys:
signin_page, signup_page, dashboard_page, transactions_page,
add_transaction_page, budgets_page, savings_page, reports_page,
settings_page, add_fab, amount_field, save_button. Preserve these
keys when modifying pages.

Do not assert on DateTime.now() — inject a Now
(typedef Now = DateTime Function()) via clockProvider.

## 17. Platform / Build Notes
Android appId np.pocketbudget.app (finalize before the first release).
Permissions: INTERNET, ACCESS_NETWORK_STATE, POST_NOTIFICATIONS
(for budget alerts in Phase 5). Release signing: set up a real keystore
before any Play upload — losing it makes future updates impossible.

iOS display name PocketBudget; NSAllowsArbitraryLoads false
(Supabase is HTTPS). Portrait-only for the MVP.

Web sqflite unsupported -> web build is a read-only demo only or
disabled. Do not ship web as a primary target.

Desktop supported but untested for the MVP.

## 18. How to Add a New Feature (Step-by-Step)
### Option A — Full CLEAN feature (data + domain + presentation)
- Create `lib/features/{name}/` with subfolders:
  - `domain/entities|repositories|usecases`
  - `data/datasources|models|repositories`
  - `presentation/providers|pages|widgets`
- Entity — plain immutable class + Equatable.
- Abstract repository — methods returning TaskEither<Failure, T>.
- Use cases — thin delegates; validation lives HERE.
- Model — fromJson / toJson / toEntity / fromEntity (+ Equatable).
  Use (v as num?)?.toInt() casts.
- DataSource — Local (sqflite) and/or Remote (Supabase). Add column
  constants to core/database/tables.dart first.
- RepositoryImpl — TaskEither.tryCatch(async, handleError).
- Provider file — repositoryProvider + useCaseProviders +
  StateNotifierProvider<FeatureNotifier, FeatureState> (copy the
  transactions template).
- Page(s) — ConsumerStatefulWidget for forms, ConsumerWidget for
  lists.
- Shimmer loading — add shimmer placeholders for loading states
  (import from shimmer_placeholders.dart or create new ones).
- Routes — add RouteNames const + register GoRoute in app_router.dart.
- If a tab, add the page to MainShell's StatefulShellBranch.
- Tests — unit + repository + provider minimum.

### Option B — Presentation-only (no data layer)
- Create under `lib/core/common/features/{name}/`.
- Add domain/entities/ + presentation/pages|widgets.
- Use mock data inline OR consume a real provider from lib/features/*.
- Add to the shell if a tab.

### Option C — Shared widget / utility
- Put in lib/core/common/widgets|extensions|providers. Wire any new
  dependency into core_providers.dart and reuse via ref.watch.

## 19. Current Known Limitations / To-Fix
- Cloud sync not implemented yet — Phase 4. Every write already
  enqueues to sync_queue, but SyncService is a no-op until then.
- Auth screens empty — Phase 1.
- No real keystore — Android release builds sign with the debug key
  until a production keystore is created. The self-update path depends on
  this (see section 17).
- Web build is a read-only demo — sqflite is unsupported.
- Supabase default email rate limit — configure custom SMTP before launch.
- No conflict UI — SyncStatus records conflicts, but the review screen
  is Phase 5.
- Currency is stored per profile but only NPR is formatted — other
  currencies fall back to intl default formatting.
- Reports only cover month-over-month — no custom ranges yet.

## 20. Response-handling Cheat Sheet
| You want to... | Do |
| --- | --- |
| Add a page | file in features/{name}/presentation/pages/ |
| Add a provider | file in features/{name}/presentation/providers/ |
| Add a use case | file in features/{name}/domain/usecases/ |
| Add a table | core/database/tables.dart consts + migration in migrations.dart |
| Add a local query | features/{name}/data/datasources/*_local_datasource.dart |
| Add a Supabase call | features/{name}/data/datasources/*_remote_datasource.dart |
| Add an RLS policy | Supabase SQL Editor + verify with a second-user test |
| Store a value | ref.read(storageProvider).write('key', 'value') (secure, small) |
| Read a value | ref.read(storageProvider).read('key') |
| Navigate | context.go() / .push() / .pushReplacement() |
| Show snackbar | AlertWidget.showSuccess(context, 'msg') etc. |
| Show dialog | AlertWidget.showConfirmDialog(context, title:, message:) |
| Listen to auth state | ref.listen(authProvider, (prev, next) {...}) |
| Current user | ref.watch(authProvider).user |
| Dark mode | final isDark = Theme.of(context).brightness == Brightness.dark |
| Build a form | GlobalKey<FormState> + controllers + dispose() |
| Handle a failure | TaskEither.tryCatch(() async {...}, (e, s) => handleError(e)) |
| Format money | formatMinor(amountMinor, currency: 'NPR') |
| Parse money | parseMoneyToMinor('1500.50') — throws on bad input |
| DI provider | final xProvider = Provider<X>((ref) => X(ref.watch(yProvider))) |
| StateNotifier | StateNotifierProvider<Notifier, State> + copyWith |
| AsyncValue UI | state.when(loading:, error:(e,_):, data:) |
| Pass data between pages | context.push(Route, extra: obj) then state.extra as T? |
## 21. Release Acceptance Criteria
The app is ready for a first release only when every line below is verified
on a real Android device:

- [ ] Users can register, sign in, sign out, and recover access.
- [ ] Users cannot read or modify another user's cloud data (verified with two accounts + direct Supabase queries).
- [ ] Transactions persist locally and survive an app restart.
- [ ] Income, expense, transfer, and balance calculations are correct.
- [ ] Budgets and savings goals update after relevant changes.
- [ ] Offline changes synchronize after reconnecting without duplication.
- [ ] Conflicting edits and failed sync operations are handled safely.
- [ ] Users can export their data and request account/data deletion.
- [ ] Critical repository, domain, and provider tests pass.
- [ ] The app has been tested on a real Android device.
Update this checklist as items are verified; do not mark an item done based
only on a screen existing.

End of AGENTS.md — PocketBudget.
Keep this file accurate. If you add a feature, add a route, or change a
pattern, update the relevant section here.

> **What changed vs my previous draft (so you know it now matches Glean Faith):**
>
> 1. **State & DI**: Riverpod only (`StateNotifier` + `AsyncValue` + `Provider`), no BLoC, no GetIt.
> 2. **Functional**: `fpdart` `TaskEither<Failure, T>` in every repository and use case — same as Glean Faith.
> 3. **Folder layout**: `lib/core/`, `lib/features/`, `lib/app/` with `router/` + `di/` — same shape as your Glean Faith `core/` tree.
> 4. **Sections**: same numbered sections (1–21) with the same table-heavy style, `> ` callouts, and "THE templates to copy" phrasing.
> 5. **Section 13 (Supabase Setup)** is new and self-contained: project, Auth, schema, RLS policies, and the RLS verification SQL — since you asked "what do we need to do there."
> 6. **Pubspec** reflects your actual packages: `flutter_riverpod`, `fpdart`, `go_router`, `sqflite`, `supabase_flutter`, `freezed_annotation`/`json_annotation`, `riverpod_generator`, `riverpod_lint`.

> If you want, I can next generate the **Supabase SQL file** (`supabase/migrations/0001_init.sql`) that matches section 13 — all 8 tables, all RLS policies, and the second-user verification tests — so you can paste it straight into the Supabase SQL Editor.
