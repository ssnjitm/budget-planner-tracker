import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../services/clock.dart';
import '../services/uuid_gen.dart';

enum SyncEntity {
  profile,
  account,
  category,
  transaction,
  budget,
  savingsGoal,
  goalEntry,
}

enum SyncOp { insert, update, delete }

class SyncOperation {
  const SyncOperation({
    required this.operationId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });

  factory SyncOperation.fromRow(Map<String, Object?> row) {
    final entityName = row[Cols.entityType] as String? ?? 'transaction';
    final opName = row[Cols.operation] as String? ?? 'insert';
    return SyncOperation(
      operationId: row[Cols.operationId] as String? ?? '',
      entity: SyncEntity.values.firstWhere(
        (value) => value.name == entityName,
        orElse: () => SyncEntity.transaction,
      ),
      entityId: row[Cols.entityId] as String? ?? '',
      op: SyncOp.values.firstWhere(
        (value) => value.name == opName,
        orElse: () => SyncOp.insert,
      ),
      createdAt: DateTime.tryParse(row[Cols.createdAt] as String? ?? '') ??
          DateTime.now().toUtc(),
      retryCount: (row[Cols.retryCount] as num?)?.toInt() ?? 0,
      lastError: row[Cols.lastError] as String?,
    );
  }

  final String operationId;
  final SyncEntity entity;
  final String entityId;
  final SyncOp op;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
}

class SyncQueue {
  SyncQueue(this._db, {UuidGen? uuid, Now? now})
      : _uuid = uuid ?? const UuidGen(),
        _now = now ?? systemNow;

  final AppDatabase _db;
  final UuidGen _uuid;
  final Now _now;

  Future<void> enqueue({
    required SyncEntity entity,
    required String entityId,
    required SyncOp op,
  }) async {
    final db = await _db.database;
    final existing = await db.query(
      Tables.syncQueue,
      columns: const [Cols.operationId],
      where: '${Cols.entityType} = ? AND ${Cols.entityId} = ? '
          'AND ${Cols.operation} = ?',
      whereArgs: [entity.name, entityId, op.name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return;
    }
    await db.insert(Tables.syncQueue, {
      Cols.operationId: _uuid.newId(),
      Cols.entityType: entity.name,
      Cols.entityId: entityId,
      Cols.operation: op.name,
      Cols.createdAt: _now().toUtc().toIso8601String(),
      Cols.retryCount: 0,
    });
  }

  Future<List<SyncOperation>> nextBatch({int limit = AppConstants.syncBatchSize}) async {
    final db = await _db.database;
    final now = _now().toUtc().toIso8601String();
    final rows = await db.query(
      Tables.syncQueue,
      where: '${Cols.nextAttemptAt} IS NULL OR ${Cols.nextAttemptAt} <= ?',
      whereArgs: [now],
      orderBy: '${Cols.createdAt} ASC',
      limit: limit,
    );
    return rows.map(SyncOperation.fromRow).toList();
  }

  Future<void> markDone(String operationId) async {
    final db = await _db.database;
    await db.delete(
      Tables.syncQueue,
      where: '${Cols.operationId} = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> markFailed(String operationId, String error) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.syncQueue,
      columns: const [Cols.retryCount],
      where: '${Cols.operationId} = ?',
      whereArgs: [operationId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return;
    }
    final retryCount = ((rows.first[Cols.retryCount] as num?)?.toInt() ?? 0) + 1;
    final String? nextAttemptAt;
    if (retryCount >= AppConstants.syncMaxAttempts) {
      nextAttemptAt = DateTime.utc(9999).toIso8601String();
    } else {
      nextAttemptAt =
          _now().toUtc().add(_backoff(retryCount)).toIso8601String();
    }
    await db.update(
      Tables.syncQueue,
      {
        Cols.retryCount: retryCount,
        Cols.lastError: error,
        Cols.nextAttemptAt: nextAttemptAt,
      },
      where: '${Cols.operationId} = ?',
      whereArgs: [operationId],
    );
  }

  Future<int> pendingCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${Tables.syncQueue}',
    );
    return (result.first['count'] as num?)?.toInt() ?? 0;
  }

  Duration _backoff(int retryCount) {
    final seconds = math.pow(2, retryCount).toInt() * 2;
    return Duration(seconds: math.min(seconds, 300));
  }
}
