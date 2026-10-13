import 'package:flutter/material.dart';

import 'shimmer_widget.dart';

class TransactionTileShimmer extends StatelessWidget {
  const TransactionTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ShimmerCircle(size: 44),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerTextLine(width: 140),
              SizedBox(height: 8),
              ShimmerTextLine(width: 90, height: 11),
            ],
          ),
        ),
        ShimmerTextLine(width: 64),
      ],
    );
  }
}

class DashboardSummaryShimmer extends StatelessWidget {
  const DashboardSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(height: 160);
}

class BudgetCardShimmer extends StatelessWidget {
  const BudgetCardShimmer({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(height: 110);
}

class SavingsGoalCardShimmer extends StatelessWidget {
  const SavingsGoalCardShimmer({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(height: 120);
}

class ReportChartShimmer extends StatelessWidget {
  const ReportChartShimmer({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(height: 200);
}

class AccountTileShimmer extends StatelessWidget {
  const AccountTileShimmer({super.key});

  @override
  Widget build(BuildContext context) => const TransactionTileShimmer();
}

class SettingsRowShimmer extends StatelessWidget {
  const SettingsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ShimmerCircle(size: 36),
        SizedBox(width: 14),
        Expanded(child: ShimmerTextLine(width: 180)),
        ShimmerTextLine(width: 24, height: 24),
      ],
    );
  }
}
