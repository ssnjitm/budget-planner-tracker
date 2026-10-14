import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  TaskEither<Failure, List<Transaction>> getAll({DateTime? from, DateTime? to});
  TaskEither<Failure, Transaction?> getById(String id);
  TaskEither<Failure, void> add(Transaction transaction);
  TaskEither<Failure, void> update(Transaction transaction);
  TaskEither<Failure, void> delete(String id);
  Stream<void> get onChange;
}
