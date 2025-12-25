import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/todo_repository.dart';

class SyncTodos {
  final TodoRepository repository;

  SyncTodos(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.syncTodos();
  }
}
