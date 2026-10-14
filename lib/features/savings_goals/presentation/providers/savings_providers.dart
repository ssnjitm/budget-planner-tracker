import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/savings_local_datasource.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/entities/goal_entry.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/savings_usecases.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepositoryImpl(
    local: SavingsLocalDataSource(ref.watch(appDatabaseProvider)),
    queue: ref.watch(syncQueueProvider),
  );
});

final getGoalsProvider = Provider<GetGoals>(
  (ref) => GetGoals(ref.watch(savingsRepositoryProvider)),
);

final addGoalProvider = Provider<AddGoal>(
  (ref) => AddGoal(ref.watch(savingsRepositoryProvider)),
);

final updateGoalProvider = Provider<UpdateGoal>(
  (ref) => UpdateGoal(ref.watch(savingsRepositoryProvider)),
);

final deleteGoalProvider = Provider<DeleteGoal>(
  (ref) => DeleteGoal(ref.watch(savingsRepositoryProvider)),
);

final getGoalEntriesProvider = Provider<GetGoalEntries>(
  (ref) => GetGoalEntries(ref.watch(savingsRepositoryProvider)),
);

final addGoalEntryProvider = Provider<AddGoalEntry>(
  (ref) => AddGoalEntry(ref.watch(savingsRepositoryProvider)),
);

final deleteGoalEntryProvider = Provider<DeleteGoalEntry>(
  (ref) => DeleteGoalEntry(ref.watch(savingsRepositoryProvider)),
);

enum SavingsStatus { initial, loading, success, error }

class SavingsState {
  const SavingsState({
    this.status = SavingsStatus.initial,
    this.goals = const [],
    this.entriesByGoal = const {},
    this.message,
  });

  final SavingsStatus status;
  final List<SavingsGoal> goals;
  final Map<String, List<GoalEntry>> entriesByGoal;
  final String? message;

  List<GoalEntry> entriesFor(String goalId) =>
      entriesByGoal[goalId] ?? const [];

  int savedMinor(String goalId) =>
      entriesFor(goalId).fold(0, (sum, entry) => sum + entry.signedMinor);

  SavingsState copyWith({
    SavingsStatus? status,
    List<SavingsGoal>? goals,
    Map<String, List<GoalEntry>>? entriesByGoal,
    String? message,
    bool clearMessage = false,
  }) {
    return SavingsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      entriesByGoal: entriesByGoal ?? this.entriesByGoal,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final savingsProvider = StateNotifierProvider<SavingsNotifier, SavingsState>((
  ref,
) {
  return SavingsNotifier(ref);
});

class SavingsNotifier extends StateNotifier<SavingsState> {
  SavingsNotifier(this._ref) : super(const SavingsState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(status: SavingsStatus.loading, clearMessage: true);
    final goalsResult = await _ref.read(getGoalsProvider).call().run();
    final entriesResult = await _ref.read(getGoalEntriesProvider).call().run();

    final goals = goalsResult.getOrElse((_) => const <SavingsGoal>[]);
    final entries = entriesResult.getOrElse((_) => const <GoalEntry>[]);
    final failure = goalsResult.isLeft()
        ? goalsResult.fold((f) => f.message, (_) => '')
        : entriesResult.fold((f) => f.message, (_) => '');

    if (goalsResult.isLeft() || entriesResult.isLeft()) {
      state = state.copyWith(status: SavingsStatus.error, message: failure);
      return;
    }

    final grouped = <String, List<GoalEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.goalId, () => []).add(entry);
    }
    state = state.copyWith(
      status: SavingsStatus.success,
      goals: goals,
      entriesByGoal: grouped,
    );
  }

  Future<bool> addGoal(SavingsGoal goal) async {
    final result = await _ref.read(addGoalProvider).call(goal).run();
    return _handle(result);
  }

  Future<bool> updateGoal(SavingsGoal goal) async {
    final result = await _ref.read(updateGoalProvider).call(goal).run();
    return _handle(result);
  }

  Future<bool> deleteGoal(String id) async {
    final result = await _ref.read(deleteGoalProvider).call(id).run();
    return _handle(result);
  }

  Future<bool> addEntry(GoalEntry entry) async {
    final result = await _ref.read(addGoalEntryProvider).call(entry).run();
    return _handle(result);
  }

  Future<bool> deleteEntry(String id) async {
    final result = await _ref.read(deleteGoalEntryProvider).call(id).run();
    return _handle(result);
  }

  bool _handle(Either<Failure, void> result) {
    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}

final totalSavedProvider = Provider<int>((ref) {
  final goals = ref.watch(savingsProvider);
  return goals.goals.fold(0, (sum, goal) => sum + goals.savedMinor(goal.id));
});
