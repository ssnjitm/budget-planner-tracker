import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amountMinor,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.toAccountId,
    this.categoryId,
    this.note,
  });

  final String id;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final TransactionType type;
  final int amountMinor;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => type == TransactionType.transfer;

  @override
  List<Object?> get props => [
    id,
    accountId,
    toAccountId,
    categoryId,
    type,
    amountMinor,
    transactionDate,
    note,
    createdAt,
    updatedAt,
  ];
}
