import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);

  final SettingsLocalDataSource _local;

  @override
  TaskEither<Failure, UserSettings> get() => TaskEither.tryCatch(
    () => _local.read(),
    (error, _) => handleError(error),
  );

  @override
  TaskEither<Failure, void> save(UserSettings settings) => TaskEither.tryCatch(
    () => _local.write(settings),
    (error, _) => handleError(error),
  );
}
