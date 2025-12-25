import 'package:todo_demo_app/core/network/dio_client.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final DioClient client;

  TodoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await client.get(ApiConstants.todosEndpoint);
      return (response.data as List).map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load todos');
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await client.post(
        ApiConstants.todosEndpoint,
        data: todo.toJson(),
      );
      return TodoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create todo');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await client.patch(
        '${ApiConstants.todosEndpoint}/${todo.id}',
        data: todo.toJson(),
      );
      return TodoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update todo');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await client.delete('${ApiConstants.todosEndpoint}/$id');
    } catch (e) {
      throw Exception('Failed to delete todo');
    }
  }
}
