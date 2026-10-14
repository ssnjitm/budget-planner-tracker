import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/goal_entry.dart';
import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  TaskEither<Failure, List<SavingsGoal>> getGoals();
  TaskEither<Failure, void> addGoal(SavingsGoal goal);
  TaskEither<Failure, void> updateGoal(SavingsGoal goal);
  TaskEither<Failure, void> deleteGoal(String id);
  TaskEither<Failure, List<GoalEntry>> getEntries();
  TaskEither<Failure, void> addEntry(GoalEntry entry);
  TaskEither<Failure, void> deleteEntry(String id);
}
