import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _loggedUserKey = 'logged_user';

  // ---------- получить всех пользователей ----------
  static Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_usersKey);
    if (jsonStr == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
  }

  // ---------- регистрация ----------
  static Future<bool> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers();

    final exists = users.any((u) => u['login'] == login);
    if (exists) return false;

    users.add({
      'login': login,
      'password': password,
    });

    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  // ---------- вход ----------
  static Future<bool> login(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers();

    final user = users.firstWhere(
          (u) => u['login'] == login && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) return false;

    await prefs.setString(_loggedUserKey, login);
    return true;
  }

  // ---------- проверка входа ----------
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_loggedUserKey);
  }

  // ---------- выход ----------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedUserKey);
  }
}
