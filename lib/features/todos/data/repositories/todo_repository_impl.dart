import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return Right(remoteTodos.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedTodos();
        if (cached.isNotEmpty) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
        return const Left(NetworkFailure('No internet and no cached data'));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo(String title) async {
    try {
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final newTodo = TodoModel(
        id: tempId,
        title: title,
        completed: false,
        userId: 1,
        isPendingSync: !(await networkInfo.isConnected),
      );

      await localDataSource.cacheTodo(newTodo);

      if (await networkInfo.isConnected) {
        try {
          final remoteTodo = await remoteDataSource.createTodo(newTodo);
          await localDataSource.deleteCachedTodo(tempId);
          await localDataSource.cacheTodo(remoteTodo);
          return Right(remoteTodo.toEntity());
        } catch (_) {
          final localPending = newTodo.copyWith(isPendingSync: true);
          await localDataSource.updateCachedTodo(localPending);
          return Right(localPending.toEntity());
        }
      }

      return Right(newTodo.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    try {
      final isOnline = await networkInfo.isConnected;
      final updatedModel = TodoModel.fromEntity(
        todo,
      ).copyWith(isPendingSync: !isOnline);

      await localDataSource.updateCachedTodo(updatedModel);

      if (isOnline) {
        try {
          final remoteTodo = await remoteDataSource.updateTodo(updatedModel);
          await localDataSource.updateCachedTodo(
            remoteTodo.copyWith(isPendingSync: false),
          );
          return Right(remoteTodo.toEntity());
        } catch (_) {
          final localPending = updatedModel.copyWith(isPendingSync: true);
          await localDataSource.updateCachedTodo(localPending);
          return Right(localPending.toEntity());
        }
      }

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(int id) async {
    try {
      await localDataSource.deleteCachedTodo(id);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteTodo(id);
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncTodos() async {
    if (!(await networkInfo.isConnected)) {
      return const Left(NetworkFailure('No connection'));
    }

    try {
      final pending = await localDataSource.getPendingSyncTodos();

      for (final todo in pending) {
        try {
          if (todo.id > 1000000) {
            final remote = await remoteDataSource.createTodo(todo);
            await localDataSource.deleteCachedTodo(todo.id);
            await localDataSource.cacheTodo(
              remote.copyWith(isPendingSync: false),
            );
          } else {
            await remoteDataSource.updateTodo(todo);
            await localDataSource.updateCachedTodo(
              todo.copyWith(isPendingSync: false),
            );
          }
        } catch (_) {
          continue;
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
