import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/todo_item.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<TaskBloc>().add(const SyncTasksEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing todos...')),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskInitial) {
            context.read<TaskBloc>().add(const LoadTasksEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TaskBloc>().add(const LoadTasksEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            final todos = state.filteredTodos;

            return Column(
              children: [
                SearchBarWidget(
                  onSearch: (query) {
                    context.read<TaskBloc>().add(SearchTasksEvent(query));
                  },
                  initialValue: state.searchQuery,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<TaskBloc>().add(const LoadTasksEvent());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: todos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery.isEmpty
                                      ? 'No todos yet!\nTap + to add one'
                                      : 'No todos found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: todos.length,
                            itemBuilder: (context, index) {
                              final todo = todos[index];
                              return TodoItem(
                                id: todo.id,
                                title: todo.title,
                                completed: todo.completed,
                                isPendingSync: todo.isPendingSync,
                                onToggle: () {
                                  context.read<TaskBloc>().add(
                                        UpdateTaskEvent(
                                          todo.copyWith(
                                            completed: !todo.completed,
                                          ),
                                        ),
                                      );
                                },
                                onDelete: () {
                                  context.read<TaskBloc>().add(
                                        DeleteTaskEvent(todo.id),
                                      );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showDialog<String>(
            context: context,
            builder: (context) => const AddTodoDialog(),
          );

          if (title != null && context.mounted) {
            context.read<TaskBloc>().add(AddTaskEvent(title));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
