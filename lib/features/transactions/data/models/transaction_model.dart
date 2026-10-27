import 'package:equatable/equatable.dart';

import '../../../../core/common/extensions/datetime_extensions.dart';
import '../../../../core/database/tables.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amountMinor,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json[Cols.id] as String? ?? '',
        categoryId: json[Cols.categoryId] as String? ?? '',
        type: json[Cols.type] as String? ?? 'expense',
        amountMinor: (json[Cols.amountMinor] as num?)?.toInt() ?? 0,
        transactionDate:
            DateTime.tryParse(json[Cols.transactionDate] as String? ?? '') ??
            DateTime.now(),
        note: json[Cols.note] as String?,
        createdAt:
            DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
            DateTime.now().toUtc(),
        updatedAt:
            DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
            DateTime.now().toUtc(),
      );

  factory TransactionModel.fromEntity(Transaction entity) => TransactionModel(
    id: entity.id,
    categoryId: entity.categoryId,
    type: entity.type.name,
    amountMinor: entity.amountMinor,
    transactionDate: entity.transactionDate,
    note: entity.note,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String categoryId;
  final String type;
  final int amountMinor;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.categoryId: categoryId,
    Cols.type: type,
    Cols.amountMinor: amountMinor,
    Cols.transactionDate: toIsoDate(transactionDate),
    Cols.note: note,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  Transaction toEntity() => Transaction(
    id: id,
    categoryId: categoryId,
    type: TransactionType.values.firstWhere(
      (value) => value.name == type,
      orElse: () => TransactionType.expense,
    ),
    amountMinor: amountMinor,
    transactionDate: transactionDate,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    categoryId,
    type,
    amountMinor,
    transactionDate,
    note,
    createdAt,
    updatedAt,
  ];
}
