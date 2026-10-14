import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/budget.dart';

class BudgetModel extends Equatable {
  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.periodStart,
    required this.limitMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json[Cols.id] as String? ?? '',
    categoryId: json[Cols.categoryId] as String? ?? '',
    periodStart: _parsePeriod(json[Cols.periodStart] as String?),
    limitMinor: (json[Cols.limitMinor] as num?)?.toInt() ?? 0,
    createdAt:
        DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
        DateTime.now().toUtc(),
    updatedAt:
        DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
        DateTime.now().toUtc(),
  );

  factory BudgetModel.fromEntity(Budget entity) => BudgetModel(
    id: entity.id,
    categoryId: entity.categoryId,
    periodStart: entity.periodStart,
    limitMinor: entity.limitMinor,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String categoryId;
  final DateTime periodStart;
  final int limitMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.categoryId: categoryId,
    Cols.periodStart: periodKey(periodStart),
    Cols.limitMinor: limitMinor,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  Budget toEntity() => Budget(
    id: id,
    categoryId: categoryId,
    periodStart: DateTime(periodStart.year, periodStart.month),
    limitMinor: limitMinor,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static String periodKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';

  static DateTime _parsePeriod(String? raw) {
    if (raw == null || raw.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    final parts = raw.split('-');
    final year = int.tryParse(parts.isNotEmpty ? parts[0] : '');
    final month = int.tryParse(parts.length > 1 ? parts[1] : '');
    if (year == null || month == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    return DateTime(year, month);
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    periodStart,
    limitMinor,
    createdAt,
    updatedAt,
  ];
}
