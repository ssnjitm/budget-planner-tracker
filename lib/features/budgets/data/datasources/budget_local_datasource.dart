import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class BudgetLocalDataSource {
  BudgetLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db.database;
    return db.query(
      Tables.budgets,
      where: '${Cols.deletedAt} IS NULL',
      orderBy: '${Cols.createdAt} DESC',
    );
  }

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.budgets,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.update(
      Tables.budgets,
      row,
      where: '${Cols.id} = ?',
      whereArgs: [row[Cols.id]],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.budgets,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}
