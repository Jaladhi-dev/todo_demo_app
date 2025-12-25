import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String title;
  final bool completed;
  final int userId;
  final bool isPendingSync;

  const Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.userId = 1,
    this.isPendingSync = false,
  });

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    int? userId,
    bool? isPendingSync,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  @override
  List<Object?> get props => [id, title, completed, userId, isPendingSync];
}
