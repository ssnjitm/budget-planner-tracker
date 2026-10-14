import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.openingBalanceMinor,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int openingBalanceMinor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

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
