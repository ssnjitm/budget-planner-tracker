import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/goal_entry.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_local_datasource.dart';
import '../models/goal_entry_model.dart';
import '../models/savings_goal_model.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  SavingsRepositoryImpl({
    required SavingsLocalDataSource local,
    required SyncQueue queue,
  }) : _local = local,
       _queue = queue;

  final SavingsLocalDataSource _local;
  final SyncQueue _queue;

  @override
  TaskEither<Failure, List<SavingsGoal>> getGoals() {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getGoals();
      return rows
          .map(SavingsGoalModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> addGoal(SavingsGoal goal) {
    return TaskEither.tryCatch(() async {
      await _local.insertGoal(SavingsGoalModel.fromEntity(goal).toJson());
      await _queue.enqueue(
        entity: SyncEntity.savingsGoal,
        entityId: goal.id,
        op: SyncOp.insert,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> updateGoal(SavingsGoal goal) {
    return TaskEither.tryCatch(() async {
      await _local.updateGoal(SavingsGoalModel.fromEntity(goal).toJson());
      await _queue.enqueue(
        entity: SyncEntity.savingsGoal,
        entityId: goal.id,
        op: SyncOp.update,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> deleteGoal(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDeleteGoal(id);
      await _queue.enqueue(
        entity: SyncEntity.savingsGoal,
        entityId: id,
        op: SyncOp.delete,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, List<GoalEntry>> getEntries() {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getEntries();
      return rows
          .map(GoalEntryModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> addEntry(GoalEntry entry) {
    return TaskEither.tryCatch(() async {
      await _local.insertEntry(GoalEntryModel.fromEntity(entry).toJson());
      await _queue.enqueue(
        entity: SyncEntity.goalEntry,
        entityId: entry.id,
        op: SyncOp.insert,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> deleteEntry(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDeleteEntry(id);
      await _queue.enqueue(
        entity: SyncEntity.goalEntry,
        entityId: id,
        op: SyncOp.delete,
      );
    }, (error, _) => handleError(error));
  }
}
