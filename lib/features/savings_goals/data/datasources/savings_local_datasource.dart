import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class SavingsLocalDataSource {
  SavingsLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await _db.database;
    return db.query(
      Tables.savingsGoals,
      where: '${Cols.deletedAt} IS NULL',
      orderBy: '${Cols.createdAt} DESC',
    );
  }

  Future<void> insertGoal(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.savingsGoals,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.update(
      Tables.savingsGoals,
      row,
      where: '${Cols.id} = ?',
      whereArgs: [row[Cols.id]],
    );
  }

  Future<void> softDeleteGoal(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.savingsGoals,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await _db.database;
    return db.query(
      Tables.goalEntries,
      where: '${Cols.deletedAt} IS NULL',
      orderBy: '${Cols.createdAt} DESC',
    );
  }

  Future<void> insertEntry(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.goalEntries,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDeleteEntry(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.goalEntries,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}
