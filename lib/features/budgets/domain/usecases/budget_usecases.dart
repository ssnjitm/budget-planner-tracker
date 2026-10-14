import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  const GetBudgets(this._repository);

  final BudgetRepository _repository;

  TaskEither<Failure, List<Budget>> call() => _repository.getAll();
}

class AddBudget {
  const AddBudget(this._repository);

  final BudgetRepository _repository;

  TaskEither<Failure, void> call(Budget budget) {
    if (budget.limitMinor <= 0) {
      return TaskEither.left(
        const ValidationFailure('Budget limit must be positive'),
      );
    }
    return _repository.add(budget);
  }
}

class UpdateBudget {
  const UpdateBudget(this._repository);

  final BudgetRepository _repository;

  TaskEither<Failure, void> call(Budget budget) {
    if (budget.limitMinor <= 0) {
      return TaskEither.left(
        const ValidationFailure('Budget limit must be positive'),
      );
    }
    return _repository.update(budget);
  }
}

class DeleteBudget {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.delete(id);
}
