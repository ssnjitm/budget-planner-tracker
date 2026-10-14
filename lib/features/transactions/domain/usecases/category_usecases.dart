import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  TaskEither<Failure, List<Category>> call() => _repository.getAll();
}

class AddCategory {
  const AddCategory(this._repository);

  final CategoryRepository _repository;

  TaskEither<Failure, void> call(Category category) {
    if (category.name.trim().isEmpty) {
      return TaskEither.left(
        const ValidationFailure('Category name is required'),
      );
    }
    return _repository.add(category);
  }
}

class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  TaskEither<Failure, void> call(Category category) {
    if (category.name.trim().isEmpty) {
      return TaskEither.left(
        const ValidationFailure('Category name is required'),
      );
    }
    return _repository.update(category);
  }
}

class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  TaskEither<Failure, void> call(String id) => _repository.delete(id);
}
