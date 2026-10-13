import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../core/common/features/home/main_shell.dart';
import '../core/common/widgets/feature_placeholder_page.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.transactions,
                builder: (context, state) =>
                    const FeaturePlaceholderPage(title: 'Transactions'),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) =>
                        const FeaturePlaceholderPage(title: 'Add transaction'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.reports,
                builder: (context, state) =>
                    const FeaturePlaceholderPage(title: 'Reports'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.goals,
                builder: (context, state) =>
                    const FeaturePlaceholderPage(title: 'Savings goals'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.more,
                builder: (context, state) =>
                    const FeaturePlaceholderPage(title: 'More'),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
}
