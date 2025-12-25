import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final String searchQuery;

  const TaskLoaded({
    required this.todos,
    List<Todo>? filteredTodos,
    this.searchQuery = '',
  }) : filteredTodos = filteredTodos ?? todos;

  TaskLoaded copyWith({
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    String? searchQuery,
  }) {
    return TaskLoaded(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [todos, filteredTodos, searchQuery];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
