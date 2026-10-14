import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/settings_usecases.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(ref.watch(storageProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);

final getSettingsProvider = Provider<GetSettings>(
  (ref) => GetSettings(ref.watch(settingsRepositoryProvider)),
);

final updateSettingsProvider = Provider<UpdateSettings>(
  (ref) => UpdateSettings(ref.watch(settingsRepositoryProvider)),
);

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
      return SettingsNotifier(
        ref.watch(getSettingsProvider),
        ref.watch(updateSettingsProvider),
      );
    });

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  SettingsNotifier(this._get, this._update)
    : super(const AsyncValue.loading()) {
    load();
  }

  final GetSettings _get;
  final UpdateSettings _update;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _get().run();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<bool> update(UserSettings settings) async {
    final result = await _update(settings).run();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = AsyncValue.data(settings);
        return true;
      },
    );
  }
}

final currencyCodeProvider = Provider<String>((ref) {
  return ref
      .watch(settingsProvider)
      .maybeWhen(
        data: (settings) => settings.currencyCode,
        orElse: () => 'NPR',
      );
});
