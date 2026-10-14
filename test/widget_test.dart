import 'package:budget_planner_tracker/app.dart';
import 'package:budget_planner_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_planner_tracker/features/savings_goals/presentation/providers/savings_providers.dart';
import 'package:budget_planner_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:budget_planner_tracker/features/transactions/presentation/providers/account_providers.dart';
import 'package:budget_planner_tracker/features/transactions/presentation/providers/category_providers.dart';
import 'package:budget_planner_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_repositories.dart';

void main() {
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(),
        ),
        accountRepositoryProvider.overrideWithValue(FakeAccountRepository()),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
        budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository()),
        savingsRepositoryProvider.overrideWithValue(FakeSavingsRepository()),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PocketBudgetApp(),
    );
  }

  testWidgets('shows the dashboard with a net worth summary', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Net worth'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Your budgets will show here'), findsOneWidget);
  });

  testWidgets('bottom navigation opens the transactions tab', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
