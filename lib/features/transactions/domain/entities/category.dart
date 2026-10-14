import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.iconKey,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String? iconKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, type, iconKey, createdAt, updatedAt];
}
