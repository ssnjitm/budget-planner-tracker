import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  TaskEither<Failure, List<Budget>> getAll();
  TaskEither<Failure, void> add(Budget budget);
  TaskEither<Failure, void> update(Budget budget);
  TaskEither<Failure, void> delete(String id);
}
