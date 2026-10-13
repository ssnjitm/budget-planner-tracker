import 'package:flutter/material.dart';

import '../../money/money.dart';
import '../../theme/app_colors.dart';

class AmountText extends StatelessWidget {
  const AmountText({
    required this.money,
    this.color,
    this.showSign = false,
    this.style,
    super.key,
  });

  final Money money;
  final Color? color;
  final bool showSign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = color ??
        (money.isNegative
            ? AppColors.expense
            : (isDark ? const Color(0xFFE2E8F0) : AppColors.textPrimary));
    final prefix = showSign && money.isNegative ? '-' : '';
    return Text(
      '$prefix${money.format()}',
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: resolved,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
