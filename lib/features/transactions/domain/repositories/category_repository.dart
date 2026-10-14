import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  TaskEither<Failure, List<Category>> getAll();
  TaskEither<Failure, void> add(Category category);
  TaskEither<Failure, void> update(Category category);
  TaskEither<Failure, void> delete(String id);
}
