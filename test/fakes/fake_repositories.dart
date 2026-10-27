import 'package:budget_planner_tracker/core/error/failures.dart';
import 'package:budget_planner_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_planner_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:budget_planner_tracker/features/savings_goals/domain/entities/goal_entry.dart';
import 'package:budget_planner_tracker/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:budget_planner_tracker/features/savings_goals/domain/repositories/savings_repository.dart';
import 'package:budget_planner_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:budget_planner_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:budget_planner_tracker/features/transactions/domain/entities/category.dart';
import 'package:budget_planner_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_planner_tracker/features/transactions/domain/repositories/category_repository.dart';
import 'package:budget_planner_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

TaskEither<Failure, void> _ok() => TaskEither<Failure, void>.right(null);

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([this.items = const []]);

  final List<Transaction> items;

  @override
  TaskEither<Failure, List<Transaction>> getAll({
    DateTime? from,
    DateTime? to,
  }) => TaskEither.right(items);

  @override
  TaskEither<Failure, Transaction?> getById(String id) {
    for (final item in items) {
      if (item.id == id) {
        return TaskEither.right(item);
      }
    }
    return TaskEither.right(null);
  }

  @override
  TaskEither<Failure, void> add(Transaction transaction) => _ok();

  @override
  TaskEither<Failure, void> update(Transaction transaction) => _ok();

  @override
  TaskEither<Failure, void> delete(String id) => _ok();

  @override
  Stream<void> get onChange => const Stream<void>.empty();
}

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([this.items = const []]);

  final List<Category> items;

  @override
  TaskEither<Failure, List<Category>> getAll() => TaskEither.right(items);

  @override
  TaskEither<Failure, void> add(Category category) => _ok();

  @override
  TaskEither<Failure, void> update(Category category) => _ok();

  @override
  TaskEither<Failure, void> delete(String id) => _ok();
}

class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository([this.items = const []]);

  final List<Budget> items;

  @override
  TaskEither<Failure, List<Budget>> getAll() => TaskEither.right(items);

  @override
  TaskEither<Failure, void> add(Budget budget) => _ok();

  @override
  TaskEither<Failure, void> update(Budget budget) => _ok();

  @override
  TaskEither<Failure, void> delete(String id) => _ok();
}

class FakeSavingsRepository implements SavingsRepository {
  FakeSavingsRepository({this.goals = const [], this.entries = const []});

  final List<SavingsGoal> goals;
  final List<GoalEntry> entries;

  @override
  TaskEither<Failure, List<SavingsGoal>> getGoals() => TaskEither.right(goals);

  @override
  TaskEither<Failure, void> addGoal(SavingsGoal goal) => _ok();

  @override
  TaskEither<Failure, void> updateGoal(SavingsGoal goal) => _ok();

  @override
  TaskEither<Failure, void> deleteGoal(String id) => _ok();

  @override
  TaskEither<Failure, List<GoalEntry>> getEntries() =>
      TaskEither.right(entries);

  @override
  TaskEither<Failure, void> addEntry(GoalEntry entry) => _ok();

  @override
  TaskEither<Failure, void> deleteEntry(String id) => _ok();
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const UserSettings()]);

  final UserSettings settings;

  @override
  TaskEither<Failure, UserSettings> get() => TaskEither.right(settings);

  @override
  TaskEither<Failure, void> save(UserSettings settings) => _ok();
}
