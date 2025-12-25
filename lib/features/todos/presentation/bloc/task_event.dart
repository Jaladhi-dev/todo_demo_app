import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

class AddTaskEvent extends TaskEvent {
  final String title;

  const AddTaskEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateTaskEvent extends TaskEvent {
  final Todo todo;

  const UpdateTaskEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTaskEvent extends TaskEvent {
  final int id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SyncTasksEvent extends TaskEvent {
  const SyncTasksEvent();
}
