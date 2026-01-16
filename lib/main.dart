import 'package:flutter/material.dart';
import 'screens/crypto_list_screen.dart'; // наш главный экран со списком валют

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF81D4FA),
        ),
      ),
      home: const CryptoListScreen(),
      // главный экран
    );
  }
}
