import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> cacheTodo(TodoModel todo);
  Future<void> updateCachedTodo(TodoModel todo);
  Future<void> deleteCachedTodo(int id);
  Future<List<TodoModel>> getPendingSyncTodos();
  Future<void> clearCache();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static const _tableName = 'todos';
  
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'todos.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, title TEXT, completed INTEGER, userId INTEGER, isPendingSync INTEGER DEFAULT 0)'
        );
      },
    );
  }

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'id DESC');
    return maps.map((m) => TodoModel.fromJson({
      ...m,
      'completed': m['completed'] == 1,
      'isPendingSync': m['isPendingSync'] == 1,
    })).toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_tableName);
      final batch = txn.batch();
      for (final todo in todos) {
        batch.insert(
          _tableName,
          todo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    final db = await database;
    await db.insert(
      _tableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCachedTodo(TodoModel todo) async {
    final db = await database;
    await db.update(
      _tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  @override
  Future<void> deleteCachedTodo(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TodoModel>> getPendingSyncTodos() async {
    final db = await database;
    final maps = await db.query(_tableName, where: 'isPendingSync = ?', whereArgs: [1]);
    return maps.map((m) => TodoModel.fromJson({
      ...m,
      'completed': m['completed'] == 1,
      'isPendingSync': m['isPendingSync'] == 1,
    })).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
  }

}

