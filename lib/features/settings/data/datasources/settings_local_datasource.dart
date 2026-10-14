import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._storage);

  final StorageService _storage;

  Future<UserSettings> read() async {
    final raw = await _storage.read(AppConstants.settingsKey);
    if (raw == null || raw.isEmpty) {
      return const UserSettings();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserSettings.fromJson(decoded);
      }
    } on FormatException {
      return const UserSettings();
    }
    return const UserSettings();
  }

  Future<void> write(UserSettings settings) =>
      _storage.write(AppConstants.settingsKey, jsonEncode(settings.toJson()));
}
