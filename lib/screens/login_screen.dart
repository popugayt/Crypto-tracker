import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'crypto_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool isLogin = true;
  String error = '';

  Future<void> _submit() async {
    bool success;

    if (isLogin) {
      success = await AuthService.login(
        _login.text,
        _password.text,
      );
    } else {
      success = await AuthService.register(
        _login.text,
        _password.text,
      );
    }

    if (!success) {
      setState(() {
        error = isLogin
            ? 'Неверный логин или пароль'
            : 'Пользователь уже существует';
      });
      return;
    }

    if (!isLogin) {
      await AuthService.login(_login.text, _password.text);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CryptoListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? 'Вход' : 'Регистрация',
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _login,
                decoration: const InputDecoration(labelText: 'Логин'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                    error = '';
                  });
                },
                child: Text(
                  isLogin
                      ? 'Создать аккаунт'
                      : 'У меня уже есть аккаунт',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
