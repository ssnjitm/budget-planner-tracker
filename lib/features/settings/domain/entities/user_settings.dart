import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  const UserSettings({
    this.displayName = 'PocketBudget user',
    this.currencyCode = 'NPR',
    this.onboarded = false,
  });

  final String displayName;
  final String currencyCode;
  final bool onboarded;

  UserSettings copyWith({
    String? displayName,
    String? currencyCode,
    bool? onboarded,
  }) {
    return UserSettings(
      displayName: displayName ?? this.displayName,
      currencyCode: currencyCode ?? this.currencyCode,
      onboarded: onboarded ?? this.onboarded,
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'currencyCode': currencyCode,
    'onboarded': onboarded,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    displayName: json['displayName'] as String? ?? 'PocketBudget user',
    currencyCode: json['currencyCode'] as String? ?? 'NPR',
    onboarded: json['onboarded'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [displayName, currencyCode, onboarded];
}
