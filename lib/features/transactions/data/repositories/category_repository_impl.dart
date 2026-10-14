import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryLocalDataSource local,
    required SyncQueue queue,
  }) : _local = local,
       _queue = queue;

  final CategoryLocalDataSource _local;
  final SyncQueue _queue;

  @override
  TaskEither<Failure, List<Category>> getAll() {
    return TaskEither.tryCatch(() async {
      final rows = await _local.getAll();
      return rows
          .map(CategoryModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> add(Category category) {
    return TaskEither.tryCatch(() async {
      await _local.insert(CategoryModel.fromEntity(category).toJson());
      await _queue.enqueue(
        entity: SyncEntity.category,
        entityId: category.id,
        op: SyncOp.insert,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> update(Category category) {
    return TaskEither.tryCatch(() async {
      await _local.update(CategoryModel.fromEntity(category).toJson());
      await _queue.enqueue(
        entity: SyncEntity.category,
        entityId: category.id,
        op: SyncOp.update,
      );
    }, (error, _) => handleError(error));
  }

  @override
  TaskEither<Failure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await _local.softDelete(id);
      await _queue.enqueue(
        entity: SyncEntity.category,
        entityId: id,
        op: SyncOp.delete,
      );
    }, (error, _) => handleError(error));
  }
}
