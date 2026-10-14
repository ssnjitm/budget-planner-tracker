import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountLocalDataSource local,
    required SyncQueue queue,
  }) : _local = local,
       _queue = queue;

  final AccountLocalDataSource _local;
  final SyncQueue _queue;

  @override
  TaskEither<Failure, List<Account>> getAll() {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getAll();
      return rows.map(AccountModel.fromJson).map((m) => m.toEntity()).toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, int> balanceMinor(String accountId) {
    return TaskEither.tryCatch(
      () => _local.balanceMinor(accountId),
      (error, _) => handleError(error),
    );
  }

  @override
  TaskEither<Failure, void> add(Account account) {
    return TaskEither.tryCatch(() async {
      await _local.insert(AccountModel.fromEntity(account).toJson());
      await _queue.enqueue(
        entity: SyncEntity.account,
        entityId: account.id,
        op: SyncOp.insert,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> update(Account account) {
    return TaskEither.tryCatch(() async {
      await _local.update(AccountModel.fromEntity(account).toJson());
      await _queue.enqueue(
        entity: SyncEntity.account,
        entityId: account.id,
        op: SyncOp.update,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDelete(id);
      await _queue.enqueue(
        entity: SyncEntity.account,
        entityId: id,
        op: SyncOp.delete,
      );
    }, (error, _) => handleError(error));
  }
}
