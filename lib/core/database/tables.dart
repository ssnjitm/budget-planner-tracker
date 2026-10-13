abstract final class Tables {
  static const profiles = 'profiles';
  static const accounts = 'accounts';
  static const categories = 'categories';
  static const transactions = 'transactions';
  static const budgets = 'budgets';
  static const savingsGoals = 'savings_goals';
  static const goalEntries = 'goal_entries';
  static const syncQueue = 'sync_queue';
}

abstract final class Cols {
  static const id = 'id';
  static const userId = 'user_id';
  static const displayName = 'display_name';
  static const currencyCode = 'currency_code';
  static const name = 'name';
  static const openingBalanceMinor = 'opening_balance_minor';
  static const isActive = 'is_active';
  static const type = 'type';
  static const iconKey = 'icon_key';
  static const accountId = 'account_id';
  static const toAccountId = 'to_account_id';
  static const categoryId = 'category_id';
  static const amountMinor = 'amount_minor';
  static const transactionDate = 'transaction_date';
  static const note = 'note';
  static const periodStart = 'period_start';
  static const limitMinor = 'limit_minor';
  static const targetMinor = 'target_minor';
  static const targetDate = 'target_date';
  static const goalId = 'goal_id';
  static const entryType = 'entry_type';
  static const syncStatus = 'sync_status';
  static const serverRevision = 'server_revision';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const deletedAt = 'deleted_at';

  static const operationId = 'operation_id';
  static const entityType = 'entity_type';
  static const entityId = 'entity_id';
  static const operation = 'operation';
  static const retryCount = 'retry_count';
  static const lastError = 'last_error';
  static const nextAttemptAt = 'next_attempt_at';
}
