import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amountMinor,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final String categoryId;
  final TransactionType type;
  final int amountMinor;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type == TransactionType.income;

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
