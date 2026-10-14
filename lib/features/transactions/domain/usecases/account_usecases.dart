import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccounts {
  const GetAccounts(this._repository);

  final AccountRepository _repository;

  TaskEither<Failure, List<Account>> call() => _repository.getAll();
}

class GetAccountBalance {
  const GetAccountBalance(this._repository);

  final AccountRepository _repository;

  TaskEither<Failure, int> call(String accountId) =>
      _repository.balanceMinor(accountId);
}

class AddAccount {
  const AddAccount(this._repository);

  final AccountRepository _repository;

  TaskEither<Failure, void> call(Account account) {
    if (account.name.trim().isEmpty) {
      return TaskEither.left(
        const ValidationFailure('Account name is required'),
      );
    }
    return _repository.add(account);
  }
}

class UpdateAccount {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  TaskEither<Failure, void> call(Account account) {
    if (account.name.trim().isEmpty) {
      return TaskEither.left(
        const ValidationFailure('Account name is required'),
      );
    }
    return _repository.update(account);
  }
}

class DeleteAccount {
  const DeleteAccount(this._repository);

  final AccountRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.delete(id);
}
