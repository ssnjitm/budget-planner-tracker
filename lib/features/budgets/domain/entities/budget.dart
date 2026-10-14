import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.periodStart,
    required this.limitMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final DateTime periodStart;
  final int limitMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

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
