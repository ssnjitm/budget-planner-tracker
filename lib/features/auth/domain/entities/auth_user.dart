import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  static const local = AuthUser(id: 'local', displayName: 'Local profile');

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  bool get isLocal => id == local.id;

  String get name {
    final value = displayName?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    final address = email?.trim();
    if (address != null && address.isNotEmpty) {
      return address.split('@').first;
    }
    return 'PocketBudget user';
  }

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'PB';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];
}
