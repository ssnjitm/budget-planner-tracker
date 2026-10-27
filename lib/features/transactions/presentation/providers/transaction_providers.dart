import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/transaction_usecases.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    local: TransactionLocalDataSource(ref.watch(appDatabaseProvider)),
    queue: ref.watch(syncQueueProvider),
  );
});

final getTransactionsProvider = Provider<GetTransactions>(
  (ref) => GetTransactions(ref.watch(transactionRepositoryProvider)),
);

final getTransactionProvider = Provider<GetTransaction>(
  (ref) => GetTransaction(ref.watch(transactionRepositoryProvider)),
);

final addTransactionProvider = Provider<AddTransaction>(
  (ref) => AddTransaction(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionProvider = Provider<UpdateTransaction>(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionProvider = Provider<DeleteTransaction>(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

enum TransactionStatus { initial, loading, success, error }

enum TransactionFilter { all, income, expense }

class TransactionState {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.items = const [],
    this.message,
    this.filter = TransactionFilter.all,
  });

  final TransactionStatus status;
  final List<Transaction> items;
  final String? message;
  final TransactionFilter filter;

  List<Transaction> get visibleItems {
    switch (filter) {
      case TransactionFilter.all:
        return items;
      case TransactionFilter.income:
        return items.where((t) => t.type == TransactionType.income).toList();
      case TransactionFilter.expense:
        return items.where((t) => t.type == TransactionType.expense).toList();
    }
  }

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? items,
    String? message,
    TransactionFilter? filter,
    bool clearMessage = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
      filter: filter ?? this.filter,
    );
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref);
    });

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._ref) : super(const TransactionState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(
      status: TransactionStatus.loading,
      clearMessage: true,
    );
    final result = await _ref.read(getTransactionsProvider).call().run();
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

  void setFilter(TransactionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<bool> add(Transaction transaction) {
    return _runMutation(_ref.read(addTransactionProvider).call(transaction));
  }

  Future<bool> update(Transaction transaction) {
    return _runMutation(_ref.read(updateTransactionProvider).call(transaction));
  }

  Future<bool> delete(String id) {
    return _runMutation(_ref.read(deleteTransactionProvider).call(id));
  }

  Future<bool> _runMutation(TaskEither<Failure, void> operation) async {
    final result = await operation.run();
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: TransactionStatus.error,
          message: failure.message,
        );
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}
