import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final int limitMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, categoryId, limitMinor, createdAt, updatedAt];
}
