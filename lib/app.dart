import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/entities/auth_state.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/budgets/presentation/providers/budget_providers.dart';
import 'features/savings_goals/presentation/providers/savings_providers.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/transactions/presentation/providers/category_providers.dart';
import 'features/transactions/presentation/providers/transaction_providers.dart';
import 'router/app_router.dart';

class PocketBudgetApp extends ConsumerWidget {
  const PocketBudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    _scheduleAuthGateUpdate(auth.status);

    ref.listen<AuthState>(authProvider, (previous, next) {
      _scheduleAuthGateUpdate(next.status);

      final wasAuthenticated = previous?.status == AuthStatus.authenticated;
      final isAuthenticated = next.status == AuthStatus.authenticated;
      final userChanged = previous?.user?.id != next.user?.id;
      if (wasAuthenticated && (!isAuthenticated || userChanged)) {
        _resetFeatureState(ref);
      }
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }

  void _scheduleAuthGateUpdate(AuthStatus status) {
    if (AppRouter.authGate.status == status) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.authGate.update(status);
    });
  }

  void _resetFeatureState(WidgetRef ref) {
    ref.invalidate(transactionProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(budgetProvider);
    ref.invalidate(savingsProvider);
    ref.invalidate(settingsProvider);
  }
}
