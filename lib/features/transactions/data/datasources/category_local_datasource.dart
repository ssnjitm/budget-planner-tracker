import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db.database;
    return db.query(
      Tables.categories,
      where: '${Cols.deletedAt} IS NULL',
      orderBy: '${Cols.type} ASC, ${Cols.name} ASC',
    );
  }

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.categories,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.update(
      Tables.categories,
      row,
      where: '${Cols.id} = ?',
      whereArgs: [row[Cols.id]],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.categories,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}
