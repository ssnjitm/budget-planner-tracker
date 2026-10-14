import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../transactions/domain/entities/category.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/category_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/budget_usecases.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(
    local: BudgetLocalDataSource(ref.watch(appDatabaseProvider)),
    queue: ref.watch(syncQueueProvider),
  );
});

final getBudgetsProvider = Provider<GetBudgets>(
  (ref) => GetBudgets(ref.watch(budgetRepositoryProvider)),
);

final addBudgetProvider = Provider<AddBudget>(
  (ref) => AddBudget(ref.watch(budgetRepositoryProvider)),
);

final updateBudgetProvider = Provider<UpdateBudget>(
  (ref) => UpdateBudget(ref.watch(budgetRepositoryProvider)),
);

final deleteBudgetProvider = Provider<DeleteBudget>(
  (ref) => DeleteBudget(ref.watch(budgetRepositoryProvider)),
);

enum BudgetStatus { initial, loading, success, error }

class BudgetState {
  const BudgetState({
    this.status = BudgetStatus.initial,
    this.items = const [],
    this.message,
  });

  final BudgetStatus status;
  final List<Budget> items;
  final String? message;

  BudgetState copyWith({
    BudgetStatus? status,
    List<Budget>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return BudgetState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier(ref);
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier(this._ref) : super(const BudgetState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(status: BudgetStatus.loading, clearMessage: true);
    final result = await _ref.read(getBudgetsProvider).call().run();
    result.fold(
      (failure) => state = state.copyWith(
        status: BudgetStatus.error,
        message: failure.message,
      ),
      (items) =>
          state = state.copyWith(status: BudgetStatus.success, items: items),
    );
  }

  Future<bool> add(Budget budget) async {
    final result = await _ref.read(addBudgetProvider).call(budget).run();
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

  Future<bool> update(Budget budget) async {
    final result = await _ref.read(updateBudgetProvider).call(budget).run();
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
    final result = await _ref.read(deleteBudgetProvider).call(id).run();
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

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    this.category,
    required this.spentMinor,
  });

  final Budget budget;
  final Category? category;
  final int spentMinor;

  int get limitMinor => budget.limitMinor;

  int get remainingMinor => limitMinor - spentMinor;

  double get ratio =>
      limitMinor <= 0 ? 0 : (spentMinor / limitMinor).clamp(0, 1).toDouble();

  String get categoryName => category?.name ?? 'Category';
}

final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetProvider).items;
  final transactions = ref.watch(transactionProvider).items;
  final categories = ref.watch(categoryProvider).items;
  final categoryById = {
    for (final category in categories) category.id: category,
  };

  return budgets.map((budget) {
    final spent = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.categoryId == budget.categoryId &&
              transaction.transactionDate.year == budget.periodStart.year &&
              transaction.transactionDate.month == budget.periodStart.month,
        )
        .fold(0, (sum, transaction) => sum + transaction.amountMinor);
    return BudgetProgress(
      budget: budget,
      category: categoryById[budget.categoryId],
      spentMinor: spent,
    );
  }).toList();
});
