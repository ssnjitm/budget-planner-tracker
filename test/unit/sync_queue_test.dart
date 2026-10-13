import 'package:budget_planner_tracker/core/database/app_database.dart';
import 'package:budget_planner_tracker/core/database/tables.dart';
import 'package:budget_planner_tracker/core/services/uuid_gen.dart';
import 'package:budget_planner_tracker/core/sync/sync_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SyncQueue queue;
  var current = DateTime.utc(2026);

  setUp(() {
    current = DateTime.utc(2026);
    db = AppDatabase(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    queue = SyncQueue(db, uuid: const UuidGen(), now: () => current);
  });

  tearDown(() => db.close());

  test('enqueue adds a single pending operation', () async {
    await queue.enqueue(
      entity: SyncEntity.transaction,
      entityId: 'tx-1',
      op: SyncOp.insert,
    );

    final batch = await queue.nextBatch();
    expect(batch, hasLength(1));
    expect(batch.single.entityId, 'tx-1');
    expect(batch.single.op, SyncOp.insert);
  });

  test('re-enqueueing the same operation is idempotent', () async {
    await queue.enqueue(
      entity: SyncEntity.transaction,
      entityId: 'tx-1',
      op: SyncOp.insert,
    );
    await queue.enqueue(
      entity: SyncEntity.transaction,
      entityId: 'tx-1',
      op: SyncOp.insert,
    );

    expect(await queue.pendingCount(), 1);
  });

  test('markDone removes the operation', () async {
    await queue.enqueue(
      entity: SyncEntity.transaction,
      entityId: 'tx-1',
      op: SyncOp.insert,
    );
    final operation = (await queue.nextBatch()).single;

    await queue.markDone(operation.operationId);

    expect(await queue.pendingCount(), 0);
    expect(await queue.nextBatch(), isEmpty);
  });

  test('a failed operation respects its backoff window', () async {
    await queue.enqueue(
      entity: SyncEntity.transaction,
      entityId: 'tx-1',
      op: SyncOp.delete,
    );
    final operation = (await queue.nextBatch()).single;

    await queue.markFailed(operation.operationId, 'offline');

    expect(await queue.nextBatch(), isEmpty);

    current = current.add(const Duration(minutes: 10));
    final retried = await queue.nextBatch();
    expect(retried, hasLength(1));
    expect(retried.single.retryCount, 1);
  });

  test('money columns are stored as integers', () async {
    final database = await db.database;
    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    for (final table in tables) {
      final name = table['name'] as String? ?? '';
      if (name.startsWith('sqlite_')) {
        continue;
      }
      final columns = await database.rawQuery('PRAGMA table_info($name)');
      for (final column in columns) {
        final columnName = column[Cols.name] as String? ?? '';
        if (!columnName.endsWith('_minor')) {
          continue;
        }
        final type = (column['type'] as String? ?? '').toUpperCase();
        expect(type, contains('INTEGER'), reason: '$name.$columnName');
      }
    }
  });
}
