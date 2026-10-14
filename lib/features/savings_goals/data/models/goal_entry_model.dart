import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/goal_entry.dart';

class GoalEntryModel extends Equatable {
  const GoalEntryModel({
    required this.id,
    required this.goalId,
    required this.amountMinor,
    required this.entryType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalEntryModel.fromJson(Map<String, dynamic> json) => GoalEntryModel(
    id: json[Cols.id] as String? ?? '',
    goalId: json[Cols.goalId] as String? ?? '',
    amountMinor: (json[Cols.amountMinor] as num?)?.toInt() ?? 0,
    entryType: json[Cols.entryType] as String? ?? 'contribute',
    createdAt:
        DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
        DateTime.now().toUtc(),
    updatedAt:
        DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
        DateTime.now().toUtc(),
  );

  factory GoalEntryModel.fromEntity(GoalEntry entity) => GoalEntryModel(
    id: entity.id,
    goalId: entity.goalId,
    amountMinor: entity.amountMinor,
    entryType: entity.entryType.name,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String goalId;
  final int amountMinor;
  final String entryType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.goalId: goalId,
    Cols.amountMinor: amountMinor,
    Cols.entryType: entryType,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  GoalEntry toEntity() => GoalEntry(
    id: id,
    goalId: goalId,
    amountMinor: amountMinor,
    entryType: entryType == 'withdraw'
        ? GoalEntryType.withdraw
        : GoalEntryType.contribute,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    goalId,
    amountMinor,
    entryType,
    createdAt,
    updatedAt,
  ];
}
