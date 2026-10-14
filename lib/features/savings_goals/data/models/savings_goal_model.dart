import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends Equatable {
  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetMinor,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      SavingsGoalModel(
        id: json[Cols.id] as String? ?? '',
        name: json[Cols.name] as String? ?? '',
        targetMinor: (json[Cols.targetMinor] as num?)?.toInt() ?? 0,
        targetDate: DateTime.tryParse(json[Cols.targetDate] as String? ?? ''),
        createdAt:
            DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
            DateTime.now().toUtc(),
        updatedAt:
            DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
            DateTime.now().toUtc(),
      );

  factory SavingsGoalModel.fromEntity(SavingsGoal entity) => SavingsGoalModel(
    id: entity.id,
    name: entity.name,
    targetMinor: entity.targetMinor,
    targetDate: entity.targetDate,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String name;
  final int targetMinor;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.name: name,
    Cols.targetMinor: targetMinor,
    Cols.targetDate: targetDate?.toIso8601String(),
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  SavingsGoal toEntity() => SavingsGoal(
    id: id,
    name: name,
    targetMinor: targetMinor,
    targetDate: targetDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    targetMinor,
    targetDate,
    createdAt,
    updatedAt,
  ];
}
