import 'package:budget_planner_tracker/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the dashboard and empty financial summary', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PocketBudgetApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('NPR 0'), findsNWidgets(4));
    expect(find.text('Your budgets will show here'), findsOneWidget);
  });

  testWidgets('bottom navigation opens feature placeholders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PocketBudgetApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();

    expect(find.text('Transactions is coming soon'), findsOneWidget);
  });
}
