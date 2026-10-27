import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'migrations.dart';
import 'tables.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? path})
    : _factory = factory,
      _path = path;

  final DatabaseFactory? _factory;
  final String? _path;

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database {
    final db = _db;
    if (db != null) {
      return Future<Database>.value(db);
    }
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    try {
      final factory = _factory ?? databaseFactory;
      final path =
          _path ??
          p.join(await factory.getDatabasesPath(), AppConstants.databaseName);
      final db = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: AppConstants.databaseVersion,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: (db, version) => createSchema(db),
          onUpgrade: (db, oldVersion, newVersion) =>
              migrate(db, oldVersion, newVersion),
        ),
      );
      _db = db;
      return db;
    } on DatabaseException catch (error) {
      throw LocalDbException(error.toString());
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _opening = null;
  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in const [
        Tables.goalEntries,
        Tables.savingsGoals,
        Tables.transactions,
        Tables.budgets,
        Tables.profiles,
        Tables.categories,
        Tables.syncQueue,
      ]) {
        await txn.delete(table);
      }
      for (final statement in defaultCategorySeedStatements) {
        await txn.execute(statement);
      }
    });
  }
}

Future<void> createSchema(Database db) async {
  for (final migration in migrations) {
    for (final statement in migration.statements) {
      await db.execute(statement);
    }
  }
}

Future<void> migrate(Database db, int oldVersion, int newVersion) async {
  for (final migration in migrations) {
    final shouldRun =
        migration.version > oldVersion && migration.version <= newVersion;
    if (!shouldRun) {
      continue;
    }
    for (final statement in migration.statements) {
      await db.execute(statement);
    }
  }
}
