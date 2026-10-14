import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetMinor,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
  });

  final String id;
  final String name;
  final int targetMinor;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

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
