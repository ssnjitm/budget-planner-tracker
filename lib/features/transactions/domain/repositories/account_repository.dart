import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  TaskEither<Failure, List<Account>> getAll();
  TaskEither<Failure, int> balanceMinor(String accountId);
  TaskEither<Failure, void> add(Account account);
  TaskEither<Failure, void> update(Account account);
  TaskEither<Failure, void> delete(String id);
}
