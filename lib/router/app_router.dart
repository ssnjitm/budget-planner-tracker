import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/common/features/home/main_shell.dart';
import '../core/common/features/home/splash_page.dart';
import '../core/services/supabase_bootstrap.dart';
import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/budgets/presentation/pages/add_edit_budget_page.dart';
import '../features/budgets/presentation/pages/budgets_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/savings_goals/presentation/pages/add_edit_goal_page.dart';
import '../features/savings_goals/presentation/pages/goal_detail_page.dart';
import '../features/savings_goals/presentation/pages/savings_goals_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/transactions/domain/entities/transaction_type.dart';
import '../features/transactions/presentation/pages/add_edit_transaction_page.dart';
import '../features/transactions/presentation/pages/categories_page.dart';
import '../features/transactions/presentation/pages/transactions_page.dart';
import 'route_names.dart';

class AuthGate extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;

  AuthStatus get status => _status;

  void update(AuthStatus status) {
    if (_status == status) {
      return;
    }
    _status = status;
    notifyListeners();
  }
}

abstract final class AppRouter {
  static final authGate = AuthGate();

  static final router = GoRouter(
    initialLocation: SupabaseBootstrap.isReady
        ? RouteNames.splash
        : RouteNames.home,
    refreshListenable: authGate,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.transactions,
                builder: (context, state) => const TransactionsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => AddEditTransactionPage(
                      initialType: _transactionTypeFromQuery(
                        state.uri.queryParameters['type'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => AddEditTransactionPage(
                      transactionId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.budgets,
                builder: (context, state) => const BudgetsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditBudgetPage(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) =>
                        AddEditBudgetPage(budgetId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.savings,
                builder: (context, state) => const SavingsGoalsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditGoalPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => GoalDetailPage(
                      goalId: state.pathParameters['id'] ?? '',
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) =>
                            AddEditGoalPage(goalId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.reports,
                builder: (context, state) => const ReportsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    if (!SupabaseBootstrap.isReady) {
      return null;
    }

    final location = state.matchedLocation;
    final isSplash = location == RouteNames.splash;
    final isAuthPage =
        location == RouteNames.signIn || location == RouteNames.signUp;

    switch (authGate.status) {
      case AuthStatus.unknown:
        return isSplash || isAuthPage ? null : RouteNames.splash;
      case AuthStatus.authenticated:
        return isSplash || isAuthPage ? RouteNames.home : null;
      case AuthStatus.unauthenticated:
        return isAuthPage ? null : RouteNames.signIn;
    }
  }

  static TransactionType? _transactionTypeFromQuery(String? value) {
    if (value == null) {
      return null;
    }
    for (final type in TransactionType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}
