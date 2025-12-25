import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/sync_todos.dart';
import '../../domain/usecases/update_todo.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final SyncTodos syncTodos;

  TaskBloc({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.syncTodos,
  }) : super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<SearchTasksEvent>(_onSearchTasks);
    on<SyncTasksEvent>(_onSyncTasks);
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await getTodos();

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (todos) => emit(TaskLoaded(todos: todos)),
    );
  }

  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      
      final result = await addTodo(event.title);

      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (newTodo) {
          final updatedTodos = [newTodo, ...currentState.todos];
          emit(TaskLoaded(
            todos: updatedTodos,
            searchQuery: currentState.searchQuery,
          ));
        },
      );
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      
      // Optimistic update
      final updatedTodos = currentState.todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();

      emit(TaskLoaded(
        todos: updatedTodos,
        searchQuery: currentState.searchQuery,
      ));

      final result = await updateTodo(event.todo);

      result.fold(
        (failure) {
          // Revert on failure
          emit(TaskLoaded(
            todos: currentState.todos,
            searchQuery: currentState.searchQuery,
          ));
          emit(TaskError(failure.message));
        },
        (updatedTodo) {
          // Update with server response
          final finalTodos = updatedTodos.map((todo) {
            return todo.id == updatedTodo.id ? updatedTodo : todo;
          }).toList();
          
          emit(TaskLoaded(
            todos: finalTodos,
            searchQuery: currentState.searchQuery,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      
      // Optimistic delete
      final updatedTodos = currentState.todos
          .where((todo) => todo.id != event.id)
          .toList();

      emit(TaskLoaded(
        todos: updatedTodos,
        searchQuery: currentState.searchQuery,
      ));

      final result = await deleteTodo(event.id);

      result.fold(
        (failure) {
          // Revert on failure
          emit(TaskLoaded(
            todos: currentState.todos,
            searchQuery: currentState.searchQuery,
          ));
          emit(TaskError(failure.message));
        },
        (_) {
          // Delete confirmed
        },
      );
    }
  }

  Future<void> _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      
      if (event.query.isEmpty) {
        emit(TaskLoaded(
          todos: currentState.todos,
          filteredTodos: currentState.todos,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.todos.where((todo) {
          return todo.title.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(TaskLoaded(
          todos: currentState.todos,
          filteredTodos: filtered,
          searchQuery: event.query,
        ));
      }
    }
  }

  Future<void> _onSyncTasks(
    SyncTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    final result = await syncTodos();

    result.fold(
      (failure) => emit(TaskError('Sync failed: ${failure.message}')),
      (_) {
        // Reload tasks after sync
        add(const LoadTasksEvent());
      },
    );
  }
}
