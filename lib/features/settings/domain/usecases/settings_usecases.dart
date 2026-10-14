import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  TaskEither<Failure, UserSettings> call() => _repository.get();
}

class UpdateSettings {
  const UpdateSettings(this._repository);

  final SettingsRepository _repository;

  TaskEither<Failure, void> call(UserSettings settings) {
    if (settings.currencyCode.trim().isEmpty) {
      return TaskEither.left(
        const ValidationFailure('Currency code is required'),
      );
    }
    return _repository.save(settings);
  }
}
