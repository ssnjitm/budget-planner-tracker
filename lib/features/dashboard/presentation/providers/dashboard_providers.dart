import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../savings_goals/presentation/providers/savings_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

class DashboardSummary {
  const DashboardSummary({
    this.incomeMinor = 0,
    this.expenseMinor = 0,
    this.netWorthMinor = 0,
    this.budgetLimitMinor = 0,
    this.budgetSpentMinor = 0,
    this.savedMinor = 0,
    this.monthExpenseMinor = 0,
  });

  final int incomeMinor;
  final int expenseMinor;
  final int netWorthMinor;
  final int budgetLimitMinor;
  final int budgetSpentMinor;
  final int savedMinor;
  final int monthExpenseMinor;

  int get netMinor => incomeMinor - expenseMinor;

  int get remainingBudgetMinor => budgetLimitMinor - budgetSpentMinor;

  double get budgetRatio => budgetLimitMinor <= 0
      ? 0
      : (budgetSpentMinor / budgetLimitMinor).clamp(0, 1).toDouble();

  int get dailyAverageMinor {
    final daysElapsed = DateTime.now().day;
    if (daysElapsed <= 0) {
      return 0;
    }
    return monthExpenseMinor ~/ daysElapsed;
  }
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final now = ref.watch(clockProvider)();
  final transactions = ref.watch(transactionProvider).items;
  final budgetProgress = ref.watch(budgetProgressProvider);
  final saved = ref.watch(totalSavedProvider);

  var income = 0;
  var expense = 0;
  var monthExpense = 0;
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amountMinor;
      continue;
    }
    expense += transaction.amountMinor;
    if (transaction.transactionDate.year == now.year &&
        transaction.transactionDate.month == now.month) {
      monthExpense += transaction.amountMinor;
    }
  }

  var budgetLimit = 0;
  var budgetSpent = 0;
  for (final progress in budgetProgress) {
    budgetLimit += progress.limitMinor;
    budgetSpent += progress.spentMinor;
  }

  return DashboardSummary(
    incomeMinor: income,
    expenseMinor: expense,
    netWorthMinor: income - expense,
    budgetLimitMinor: budgetLimit,
    budgetSpentMinor: budgetSpent,
    savedMinor: saved,
    monthExpenseMinor: monthExpense,
  );
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final items = ref.watch(transactionProvider).items;
  return items.take(5).toList();
});
