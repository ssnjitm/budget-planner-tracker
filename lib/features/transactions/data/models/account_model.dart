import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';
import '../../domain/entities/account.dart';

class AccountModel extends Equatable {
  const AccountModel({
    required this.id,
    required this.name,
    required this.openingBalanceMinor,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    id: json[Cols.id] as String? ?? '',
    name: json[Cols.name] as String? ?? '',
    openingBalanceMinor: (json[Cols.openingBalanceMinor] as num?)?.toInt() ?? 0,
    isActive: ((json[Cols.isActive] as num?)?.toInt() ?? 1) == 1,
    createdAt:
        DateTime.tryParse(json[Cols.createdAt] as String? ?? '') ??
        DateTime.now().toUtc(),
    updatedAt:
        DateTime.tryParse(json[Cols.updatedAt] as String? ?? '') ??
        DateTime.now().toUtc(),
  );

  factory AccountModel.fromEntity(Account entity) => AccountModel(
    id: entity.id,
    name: entity.name,
    openingBalanceMinor: entity.openingBalanceMinor,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  final String id;
  final String name;
  final int openingBalanceMinor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    Cols.id: id,
    Cols.name: name,
    Cols.openingBalanceMinor: openingBalanceMinor,
    Cols.isActive: isActive ? 1 : 0,
    Cols.createdAt: createdAt.toUtc().toIso8601String(),
    Cols.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  Account toEntity() => Account(
    id: id,
    name: name,
    openingBalanceMinor: openingBalanceMinor,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    openingBalanceMinor,
    isActive,
    createdAt,
    updatedAt,
  ];
}
