import 'package:flutter/material.dart';

import '../../../../core/common/category_icons.dart';
import '../../../../core/common/widgets/amount_text.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.title,
    this.subtitle,
    this.iconKey,
    this.currency = 'NPR',
    this.onTap,
    super.key,
  });

  final Transaction transaction;
  final String title;
  final String? subtitle;
  final String? iconKey;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final signedMinor = isIncome
        ? transaction.amountMinor
        : -transaction.amountMinor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  CategoryIcons.resolve(iconKey),
                  color: color,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AmountText(
              money: Money.fromMinor(signedMinor, currency),
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
