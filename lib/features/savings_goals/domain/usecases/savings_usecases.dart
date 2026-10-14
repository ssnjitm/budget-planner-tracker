import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/goal_entry.dart';
import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

class GetGoals {
  const GetGoals(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, List<SavingsGoal>> call() => _repository.getGoals();
}

class AddGoal {
  const AddGoal(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, void> call(SavingsGoal goal) {
    if (goal.name.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Goal name is required'));
    }
    if (goal.targetMinor <= 0) {
      return TaskEither.left(
        const ValidationFailure('Target must be positive'),
      );
    }
    return _repository.addGoal(goal);
  }
}

class UpdateGoal {
  const UpdateGoal(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, void> call(SavingsGoal goal) {
    if (goal.name.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Goal name is required'));
    }
    if (goal.targetMinor <= 0) {
      return TaskEither.left(
        const ValidationFailure('Target must be positive'),
      );
    }
    return _repository.updateGoal(goal);
  }
}

class DeleteGoal {
  const DeleteGoal(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.deleteGoal(id);
}

class GetGoalEntries {
  const GetGoalEntries(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, List<GoalEntry>> call() => _repository.getEntries();
}

class AddGoalEntry {
  const AddGoalEntry(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, void> call(GoalEntry entry) {
    if (entry.amountMinor <= 0) {
      return TaskEither.left(
        const ValidationFailure('Amount must be positive'),
      );
    }
    return _repository.addEntry(entry);
  }
}

class DeleteGoalEntry {
  const DeleteGoalEntry(this._repository);

  final SavingsRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.deleteEntry(id);
}
