import 'package:flutter/material.dart';

abstract final class CategoryIcons {
  static const _icons = <String, IconData>{
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_bus_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'bills': Icons.receipt_long_rounded,
    'health': Icons.favorite_rounded,
    'entertainment': Icons.movie_rounded,
    'other': Icons.category_rounded,
    'salary': Icons.payments_rounded,
    'business': Icons.work_rounded,
    'gifts': Icons.card_giftcard_rounded,
    'other_income': Icons.savings_rounded,
  };

  static IconData resolve(String? key) => _icons[key] ?? Icons.category_rounded;

  static List<String> get keys => _icons.keys.toList(growable: false);
}
