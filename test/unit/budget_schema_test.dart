import 'package:budget_planner_tracker/core/database/app_database.dart';
import 'package:budget_planner_tracker/core/database/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase appDatabase;
  late Database database;

  setUp(() async {
    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    database = await appDatabase.database;
  });

  tearDown(() => appDatabase.close());

  Map<String, Object?> budget({required String id, String? deletedAt}) {
    return {
      Cols.id: id,
      Cols.categoryId: '22222222-2222-4222-8222-000000000001',
      Cols.limitMinor: 100000,
      Cols.createdAt: '2026-10-01T00:00:00.000Z',
      Cols.updatedAt: '2026-10-01T00:00:00.000Z',
      Cols.deletedAt: deletedAt,
    };
  }

  test(
    'allows a new active budget after the previous one is soft deleted',
    () async {
      await database.insert(Tables.budgets, budget(id: 'budget-1'));
      await database.update(
        Tables.budgets,
        {Cols.deletedAt: '2026-10-02T00:00:00.000Z'},
        where: '${Cols.id} = ?',
        whereArgs: ['budget-1'],
      );

      await database.insert(Tables.budgets, budget(id: 'budget-2'));

      expect(await database.query(Tables.budgets), hasLength(2));
    },
  );

  test('rejects two active budgets for the same category', () async {
    await database.insert(Tables.budgets, budget(id: 'budget-1'));

    await expectLater(
      database.insert(Tables.budgets, budget(id: 'budget-2')),
      throwsA(isA<DatabaseException>()),
    );
  });
}
