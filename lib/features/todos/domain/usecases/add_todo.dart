import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class AddTodo {
  final TodoRepository repository;

  AddTodo(this.repository);

  Future<Either<Failure, Todo>> call(String title) async {
    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }
    return await repository.addTodo(title);
  }
}
