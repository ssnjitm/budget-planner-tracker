import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class TransactionLocalDataSource {
  TransactionLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAll({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db.database;
    final where = <String>['${Cols.deletedAt} IS NULL'];
    final args = <Object?>[];
    if (from != null) {
      where.add('${Cols.transactionDate} >= ?');
      args.add(_isoDate(from));
    }
    if (to != null) {
      where.add('${Cols.transactionDate} <= ?');
      args.add(_isoDate(to));
    }
    final rows = await db.query(
      Tables.transactions,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: '${Cols.transactionDate} DESC, ${Cols.createdAt} DESC',
    );
    return rows;
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.transactions,
      where: '${Cols.id} = ? AND ${Cols.deletedAt} IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.transactions,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.update(
      Tables.transactions,
      row,
      where: '${Cols.id} = ?',
      whereArgs: [row[Cols.id]],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.transactions,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}

String _isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
