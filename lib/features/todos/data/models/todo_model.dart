import '../../domain/entities/todo.dart';

class TodoModel {
  final int id;
  final String title;
  final bool completed;
  final int userId;
  final bool isPendingSync;

  const TodoModel({
    required this.id,
    required this.title,
    required this.completed,
    this.userId = 1,
    this.isPendingSync = false,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      userId: json['userId'] as int? ?? 1,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'userId': userId,
      'isPendingSync': isPendingSync ? 1 : 0,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed ? 1 : 0,
      'userId': userId,
      'isPendingSync': isPendingSync ? 1 : 0,
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      completed: todo.completed,
      userId: todo.userId,
      isPendingSync: todo.isPendingSync,
    );
  }

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      completed: completed,
      userId: userId,
      isPendingSync: isPendingSync,
    );
  }

  TodoModel copyWith({
    int? id,
    String? title,
    bool? completed,
    int? userId,
    bool? isPendingSync,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}

