import 'tables.dart';

class Migration {
  const Migration(this.version, this.statements);

  final int version;
  final List<String> statements;
}

const List<Migration> migrations = [
  Migration(1, [
    '''
    CREATE TABLE ${Tables.profiles} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.displayName} TEXT,
      ${Cols.currencyCode} TEXT NOT NULL DEFAULT 'NPR',
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.accounts} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.name} TEXT NOT NULL,
      ${Cols.openingBalanceMinor} INTEGER NOT NULL DEFAULT 0,
      ${Cols.isActive} INTEGER NOT NULL DEFAULT 1,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.categories} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.name} TEXT NOT NULL,
      ${Cols.type} TEXT NOT NULL,
      ${Cols.iconKey} TEXT,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.transactions} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.accountId} TEXT NOT NULL,
      ${Cols.toAccountId} TEXT,
      ${Cols.categoryId} TEXT,
      ${Cols.type} TEXT NOT NULL,
      ${Cols.amountMinor} INTEGER NOT NULL,
      ${Cols.transactionDate} TEXT NOT NULL,
      ${Cols.note} TEXT,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.budgets} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.categoryId} TEXT NOT NULL,
      ${Cols.periodStart} TEXT NOT NULL,
      ${Cols.limitMinor} INTEGER NOT NULL,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.savingsGoals} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.name} TEXT NOT NULL,
      ${Cols.targetMinor} INTEGER NOT NULL,
      ${Cols.targetDate} TEXT,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.goalEntries} (
      ${Cols.id} TEXT PRIMARY KEY,
      ${Cols.goalId} TEXT NOT NULL,
      ${Cols.amountMinor} INTEGER NOT NULL,
      ${Cols.entryType} TEXT NOT NULL,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.updatedAt} TEXT NOT NULL,
      ${Cols.deletedAt} TEXT,
      ${Cols.syncStatus} TEXT NOT NULL DEFAULT 'pending',
      ${Cols.serverRevision} INTEGER NOT NULL DEFAULT 0
    )
    ''',
    '''
    CREATE TABLE ${Tables.syncQueue} (
      ${Cols.operationId} TEXT PRIMARY KEY,
      ${Cols.entityType} TEXT NOT NULL,
      ${Cols.entityId} TEXT NOT NULL,
      ${Cols.operation} TEXT NOT NULL,
      ${Cols.createdAt} TEXT NOT NULL,
      ${Cols.retryCount} INTEGER NOT NULL DEFAULT 0,
      ${Cols.lastError} TEXT,
      ${Cols.nextAttemptAt} TEXT
    )
    ''',
    'CREATE INDEX idx_tx_date ON ${Tables.transactions} (${Cols.transactionDate})',
    'CREATE INDEX idx_tx_account ON ${Tables.transactions} (${Cols.accountId})',
    'CREATE INDEX idx_budget_period ON ${Tables.budgets} (${Cols.periodStart})',
    'CREATE INDEX idx_sync_due ON ${Tables.syncQueue} (${Cols.nextAttemptAt})',
    ..._seedStatements,
  ]),
];

const String _seedTimestamp = '2026-01-01T00:00:00.000Z';

const List<String> _seedStatements = [
  '''
  INSERT OR IGNORE INTO ${Tables.accounts}
    (${Cols.id}, ${Cols.name}, ${Cols.openingBalanceMinor}, ${Cols.isActive},
     ${Cols.createdAt}, ${Cols.updatedAt}, ${Cols.syncStatus}, ${Cols.serverRevision})
  VALUES ('11111111-1111-4111-8111-111111111111', 'Cash', 0, 1,
          '$_seedTimestamp', '$_seedTimestamp', 'synced', 0)
  ''',
  '''
  INSERT OR IGNORE INTO ${Tables.categories}
    (${Cols.id}, ${Cols.name}, ${Cols.type}, ${Cols.iconKey},
     ${Cols.createdAt}, ${Cols.updatedAt}, ${Cols.syncStatus}, ${Cols.serverRevision})
  VALUES
    ('22222222-2222-4222-8222-000000000001', 'Food', 'expense', 'food',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000002', 'Transport', 'expense', 'transport',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000003', 'Shopping', 'expense', 'shopping',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000004', 'Bills', 'expense', 'bills',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000005', 'Health', 'expense', 'health',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000006', 'Entertainment', 'expense', 'entertainment',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('22222222-2222-4222-8222-000000000007', 'Other', 'expense', 'other',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('33333333-3333-4333-8333-000000000001', 'Salary', 'income', 'salary',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('33333333-3333-4333-8333-000000000002', 'Business', 'income', 'business',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('33333333-3333-4333-8333-000000000003', 'Gifts', 'income', 'gifts',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0),
    ('33333333-3333-4333-8333-000000000004', 'Other income', 'income', 'other_income',
     '$_seedTimestamp', '$_seedTimestamp', 'synced', 0)
  ''',
];
