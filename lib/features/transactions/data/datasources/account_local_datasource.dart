import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class AccountLocalDataSource {
  AccountLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db.database;
    return db.query(
      Tables.accounts,
      where: '${Cols.deletedAt} IS NULL',
      orderBy: '${Cols.createdAt} ASC',
    );
  }

  Future<int> balanceMinor(String accountId) async {
    final db = await _db.database;
    final account = await db.query(
      Tables.accounts,
      columns: const [Cols.openingBalanceMinor],
      where: '${Cols.id} = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    final opening = account.isEmpty
        ? 0
        : (account.first[Cols.openingBalanceMinor] as num?)?.toInt() ?? 0;

    final income = await db.rawQuery(
      'SELECT COALESCE(SUM(${Cols.amountMinor}), 0) AS total '
      'FROM ${Tables.transactions} '
      'WHERE ${Cols.accountId} = ? AND ${Cols.type} = ? AND ${Cols.deletedAt} IS NULL',
      [accountId, 'income'],
    );
    final expense = await db.rawQuery(
      'SELECT COALESCE(SUM(${Cols.amountMinor}), 0) AS total '
      'FROM ${Tables.transactions} '
      'WHERE ${Cols.accountId} = ? AND ${Cols.type} = ? AND ${Cols.deletedAt} IS NULL',
      [accountId, 'expense'],
    );
    final transfersIn = await db.rawQuery(
      'SELECT COALESCE(SUM(${Cols.amountMinor}), 0) AS total '
      'FROM ${Tables.transactions} '
      'WHERE ${Cols.toAccountId} = ? AND ${Cols.deletedAt} IS NULL',
      [accountId],
    );
    final transfersOut = await db.rawQuery(
      'SELECT COALESCE(SUM(${Cols.amountMinor}), 0) AS total '
      'FROM ${Tables.transactions} '
      'WHERE ${Cols.accountId} = ? AND ${Cols.type} = ? AND ${Cols.deletedAt} IS NULL',
      [accountId, 'transfer'],
    );

    int total(List<Map<String, Object?>> rows) =>
        (rows.first['total'] as num?)?.toInt() ?? 0;

    return opening +
        total(income) -
        total(expense) +
        total(transfersIn) -
        total(transfersOut);
  }

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.insert(
      Tables.accounts,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Map<String, dynamic> row) async {
    final db = await _db.database;
    await db.update(
      Tables.accounts,
      row,
      where: '${Cols.id} = ?',
      whereArgs: [row[Cols.id]],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      Tables.accounts,
      {Cols.deletedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${Cols.id} = ?',
      whereArgs: [id],
    );
  }
}
