import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.iconKey,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json[Cols.id] as String? ?? '',
    name: json[Cols.name] as String? ?? '',
    type: json[Cols.type] as String? ?? 'expense',
    iconKey: json[Cols.iconKey] as String?,
    createdAt:
        DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
        DateTime.now().toUtc(),
    updatedAt:
        DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
        DateTime.now().toUtc(),
  );

  factory CategoryModel.fromEntity(Category entity) => CategoryModel(
    id: entity.id,
    name: entity.name,
    type: entity.type.name,
    iconKey: entity.iconKey,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String name;
  final String type;
  final String? iconKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.name: name,
    Cols.type: type,
    Cols.iconKey: iconKey,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  Category toEntity() => Category(
    id: id,
    name: name,
    type: TransactionType.values.firstWhere(
      (value) => value.name == type,
      orElse: () => TransactionType.expense,
    ),
    iconKey: iconKey,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [id, name, type, iconKey, createdAt, updatedAt];
}
