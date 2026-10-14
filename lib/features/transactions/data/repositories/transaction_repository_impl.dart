import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionLocalDataSource local,
    required SyncQueue queue,
  }) : _local = local,
       _queue = queue;

  final TransactionLocalDataSource _local;
  final SyncQueue _queue;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  TaskEither<Failure, List<Transaction>> getAll({
    DateTime? from,
    DateTime? to,
  }) {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getAll(from: from, to: to);
      return rows
          .map(TransactionModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, Transaction?> getById(String id) {
    return TaskEither.tryCatch(() async {
      final row = await _local.getById(id);
      return row == null ? null : TransactionModel.fromJson(row).toEntity();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> add(Transaction transaction) {
    return TaskEither.tryCatch(() async {
      await _local.insert(TransactionModel.fromEntity(transaction).toJson());
      await _queue.enqueue(
        entity: SyncEntity.transaction,
        entityId: transaction.id,
        op: SyncOp.insert,
      );
      _changes.add(null);
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> update(Transaction transaction) {
    return TaskEither.tryCatch(() async {
      await _local.update(TransactionModel.fromEntity(transaction).toJson());
      await _queue.enqueue(
        entity: SyncEntity.transaction,
        entityId: transaction.id,
        op: SyncOp.update,
      );
      _changes.add(null);
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDelete(id);
      await _queue.enqueue(
        entity: SyncEntity.transaction,
        entityId: id,
        op: SyncOp.delete,
      );
      _changes.add(null);
    }, (error, _) => handleError(error));
  }

  @override
  Stream<void> get onChange => _changes.stream;
}
