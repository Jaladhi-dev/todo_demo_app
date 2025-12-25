import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/todos/presentation/pages/todo_list_page.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../injection_container.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authDataSource = sl<AuthLocalDataSource>();
      final isAuthenticated = await authDataSource.getAuthStatus();
      
      if (!isAuthenticated && state.uri.path != '/login') {
        return '/login';
      }
      if (isAuthenticated && state.uri.path == '/login') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TodoListPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(authDataSource: sl<AuthLocalDataSource>()),
      ),
    ],
  );
}
