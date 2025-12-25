import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthStatus(bool isAuthenticated);
  Future<bool> getAuthStatus();
  Future<void> clearAuthStatus();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _authKey = 'is_authenticated';
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveAuthStatus(bool isAuthenticated) async {
    await sharedPreferences.setBool(_authKey, isAuthenticated);
  }

  @override
  Future<bool> getAuthStatus() async {
    return sharedPreferences.getBool(_authKey) ?? false;
  }

  @override
  Future<void> clearAuthStatus() async {
    await sharedPreferences.remove(_authKey);
  }
}
