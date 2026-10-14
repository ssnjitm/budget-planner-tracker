import 'package:equatable/equatable.dart';

enum GoalEntryType { contribute, withdraw }

class GoalEntry extends Equatable {
  const GoalEntry({
    required this.id,
    required this.goalId,
    required this.amountMinor,
    required this.entryType,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String goalId;
  final int amountMinor;
  final GoalEntryType entryType;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get signedMinor =>
      entryType == GoalEntryType.contribute ? amountMinor : -amountMinor;

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
