import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  TaskEither<Failure, List<Transaction>> call({DateTime? from, DateTime? to}) =>
      _repository.getAll(from: from, to: to);
}

class GetTransaction {
  const GetTransaction(this._repository);

  final TransactionRepository _repository;

  TaskEither<Failure, Transaction?> call(String id) => _repository.getById(id);
}

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  TaskEither<Failure, void> call(Transaction transaction) {
    final validation = _validate(transaction);
    if (validation case final failure?) {
      return TaskEither.left(failure);
    }
    return _repository.add(transaction);
  }
}

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  TaskEither<Failure, void> call(Transaction transaction) {
    final validation = _validate(transaction);
    if (validation case final failure?) {
      return TaskEither.left(failure);
    }
    return _repository.update(transaction);
  }
}

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.delete(id);
}

ValidationFailure? _validate(Transaction transaction) {
  if (transaction.amountMinor <= 0) {
    return const ValidationFailure('Amount must be positive');
  }
  if (transaction.type == TransactionType.transfer) {
    if (transaction.toAccountId == null) {
      return const ValidationFailure('Transfer needs a destination account');
    }
    if (transaction.toAccountId == transaction.accountId) {
      return const ValidationFailure('Cannot transfer to the same account');
    }
  } else if (transaction.categoryId == null) {
    return const ValidationFailure('Pick a category');
  }
  return null;
}
