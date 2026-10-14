import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required BudgetLocalDataSource local,
    required SyncQueue queue,
  }) : _local = local,
       _queue = queue;

  final BudgetLocalDataSource _local;
  final SyncQueue _queue;

  @override
  TaskEither<Failure, List<Budget>> getAll() {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getAll();
      return rows.map(BudgetModel.fromJson).map((m) => m.toEntity()).toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> add(Budget budget) {
    return TaskEither.tryCatch(() async {
      await _local.insert(BudgetModel.fromEntity(budget).toJson());
      await _queue.enqueue(
        entity: SyncEntity.budget,
        entityId: budget.id,
        op: SyncOp.insert,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> update(Budget budget) {
    return TaskEither.tryCatch(() async {
      await _local.update(BudgetModel.fromEntity(budget).toJson());
      await _queue.enqueue(
        entity: SyncEntity.budget,
        entityId: budget.id,
        op: SyncOp.update,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDelete(id);
      await _queue.enqueue(
        entity: SyncEntity.budget,
        entityId: id,
        op: SyncOp.delete,
      );
    }, (error, _) => handleError(error));
  }
}
