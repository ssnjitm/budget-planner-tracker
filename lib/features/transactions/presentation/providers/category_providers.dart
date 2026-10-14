import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/common/providers/core_providers.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/category_usecases.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    local: CategoryLocalDataSource(ref.watch(appDatabaseProvider)),
    queue: ref.watch(syncQueueProvider),
  );
});

final getCategoriesProvider = Provider<GetCategories>(
  (ref) => GetCategories(ref.watch(categoryRepositoryProvider)),
);

final addCategoryProvider = Provider<AddCategory>(
  (ref) => AddCategory(ref.watch(categoryRepositoryProvider)),
);

final updateCategoryProvider = Provider<UpdateCategory>(
  (ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)),
);

final deleteCategoryProvider = Provider<DeleteCategory>(
  (ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)),
);

enum CategoryStatus { initial, loading, success, error }

class CategoryState {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.items = const [],
    this.message,
  });

  final CategoryStatus status;
  final List<Category> items;
  final String? message;

  List<Category> byType(TransactionType type) =>
      items.where((category) => category.type == type).toList();

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    return CategoryNotifier(ref);
  },
);

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier(this._ref) : super(const CategoryState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(status: CategoryStatus.loading, clearMessage: true);
    final result = await _ref.read(getCategoriesProvider).call().run();
    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        message: failure.message,
      ),
      (items) =>
          state = state.copyWith(status: CategoryStatus.success, items: items),
    );
  }

  Future<bool> add(Category category) async {
    final result = await _ref.read(addCategoryProvider).call(category).run();
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

  Future<bool> update(Category category) async {
    final result = await _ref.read(updateCategoryProvider).call(category).run();
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

  Future<bool> delete(String id) async {
    final result = await _ref.read(deleteCategoryProvider).call(id).run();
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
