import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/budget.dart';

class BudgetModel extends Equatable {
  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json[Cols.id] as String? ?? '',
    categoryId: json[Cols.categoryId] as String? ?? '',
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
    limitMinor: entity.limitMinor,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String categoryId;
  final int limitMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.categoryId: categoryId,
    Cols.limitMinor: limitMinor,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  Budget toEntity() => Budget(
    id: id,
    categoryId: categoryId,
    limitMinor: limitMinor,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [id, categoryId, limitMinor, createdAt, updatedAt];
}
