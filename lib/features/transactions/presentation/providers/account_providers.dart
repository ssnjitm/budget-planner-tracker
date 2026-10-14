import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../data/datasources/account_local_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/account_usecases.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(
    local: AccountLocalDataSource(ref.watch(appDatabaseProvider)),
    queue: ref.watch(syncQueueProvider),
  );
});

final getAccountsProvider = Provider<GetAccounts>(
  (ref) => GetAccounts(ref.watch(accountRepositoryProvider)),
);

final getAccountBalanceProvider = Provider<GetAccountBalance>(
  (ref) => GetAccountBalance(ref.watch(accountRepositoryProvider)),
);

final addAccountProvider = Provider<AddAccount>(
  (ref) => AddAccount(ref.watch(accountRepositoryProvider)),
);

final updateAccountProvider = Provider<UpdateAccount>(
  (ref) => UpdateAccount(ref.watch(accountRepositoryProvider)),
);

final deleteAccountProvider = Provider<DeleteAccount>(
  (ref) => DeleteAccount(ref.watch(accountRepositoryProvider)),
);

enum AccountStatus { initial, loading, success, error }

class AccountState {
  const AccountState({
    this.status = AccountStatus.initial,
    this.items = const [],
    this.balances = const {},
    this.message,
  });

  final AccountStatus status;
  final List<Account> items;
  final Map<String, int> balances;
  final String? message;

  int get totalBalanceMinor =>
      balances.values.fold(0, (sum, value) => sum + value);

  AccountState copyWith({
    AccountStatus? status,
    List<Account>? items,
    Map<String, int>? balances,
    String? message,
    bool clearMessage = false,
  }) {
    return AccountState(
      status: status ?? this.status,
      items: items ?? this.items,
      balances: balances ?? this.balances,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((
  ref,
) {
  return AccountNotifier(ref);
});

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier(this._ref) : super(const AccountState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(status: AccountStatus.loading, clearMessage: true);
    final result = await _ref.read(getAccountsProvider).call().run();
    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AccountStatus.error,
          message: failure.message,
        );
      },
      (items) async {
        state = state.copyWith(status: AccountStatus.success, items: items);
        await refreshBalances();
      },
    );
  }

  Future<void> refreshBalances() async {
    final balances = <String, int>{};
    final usecase = _ref.read(getAccountBalanceProvider);
    for (final account in state.items) {
      final result = await usecase.call(account.id).run();
      result.fold(
        (_) => balances[account.id] = account.openingBalanceMinor,
        (value) => balances[account.id] = value,
      );
    }
    state = state.copyWith(balances: balances);
  }

  Future<bool> add(Account account) async {
    final result = await _ref.read(addAccountProvider).call(account).run();
    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }

  Future<bool> update(Account account) async {
    final result = await _ref.read(updateAccountProvider).call(account).run();
    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }

  Future<bool> delete(String id) async {
    final result = await _ref.read(deleteAccountProvider).call(id).run();
    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}
