import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../transactions/domain/entities/category.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/category_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

class MonthlyPoint {
  const MonthlyPoint({
    required this.month,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final DateTime month;
  final int incomeMinor;
  final int expenseMinor;

  int get netMinor => incomeMinor - expenseMinor;
}

class CategorySlice {
  const CategorySlice({
    required this.name,
    required this.totalMinor,
    this.iconKey,
  });

  final String name;
  final int totalMinor;
  final String? iconKey;
}

class ReportRange {
  const ReportRange({
    required this.from,
    required this.to,
    this.transactionCount = 0,
    this.incomeMinor = 0,
    this.expenseMinor = 0,
  });

  final DateTime from;
  final DateTime to;
  final int transactionCount;
  final int incomeMinor;
  final int expenseMinor;

  int get netMinor => incomeMinor - expenseMinor;

  double get savingsRate {
    if (incomeMinor <= 0) {
      return 0;
    }
    return (incomeMinor - expenseMinor) / incomeMinor;
  }
}

final selectedReportMonthProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider)();
  return DateTime(now.year, now.month);
});

final monthlySeriesProvider = Provider<List<MonthlyPoint>>((ref) {
  final anchor = ref.watch(selectedReportMonthProvider);
  final transactions = ref.watch(transactionProvider).items;

  final months = <MonthlyPoint>[];
  for (var offset = 5; offset >= 0; offset--) {
    final month = DateTime(anchor.year, anchor.month - offset);
    var income = 0;
    var expense = 0;
    for (final transaction in transactions) {
      if (transaction.transactionDate.year != month.year ||
          transaction.transactionDate.month != month.month) {
        continue;
      }
      if (transaction.type == TransactionType.income) {
        income += transaction.amountMinor;
      } else if (transaction.type == TransactionType.expense) {
        expense += transaction.amountMinor;
      }
    }
    months.add(
      MonthlyPoint(month: month, incomeMinor: income, expenseMinor: expense),
    );
  }
  return months;
});

final reportRangeProvider = Provider<ReportRange>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final transactions = ref.watch(transactionProvider).items;
  final from = DateTime(month.year, month.month);
  final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  var income = 0;
  var expense = 0;
  var count = 0;
  for (final transaction in transactions) {
    if (transaction.transactionDate.year != month.year ||
        transaction.transactionDate.month != month.month) {
      continue;
    }
    count++;
    if (transaction.type == TransactionType.income) {
      income += transaction.amountMinor;
    } else if (transaction.type == TransactionType.expense) {
      expense += transaction.amountMinor;
    }
  }

  return ReportRange(
    from: from,
    to: to,
    transactionCount: count,
    incomeMinor: income,
    expenseMinor: expense,
  );
});

final categoryBreakdownProvider = Provider<List<CategorySlice>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final transactions = ref.watch(transactionProvider).items;
  final categories = ref.watch(categoryProvider).items;
  final categoryById = {
    for (final Category category in categories) category.id: category,
  };

  final totals = <String, int>{};
  for (final transaction in transactions) {
    if (transaction.type != TransactionType.expense) {
      continue;
    }
    if (transaction.transactionDate.year != month.year ||
        transaction.transactionDate.month != month.month) {
      continue;
    }
    final key = transaction.categoryId;
    totals[key] = (totals[key] ?? 0) + transaction.amountMinor;
  }

  final slices = totals.entries.map((entry) {
    final category = categoryById[entry.key];
    return CategorySlice(
      name: category?.name ?? 'Uncategorised',
      iconKey: category?.iconKey,
      totalMinor: entry.value,
    );
  }).toList()..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));

  return slices;
});
