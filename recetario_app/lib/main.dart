import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const RecetarioApp());

class RecetarioApp extends StatelessWidget {
  const RecetarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Recetario',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE4572E),
          primary: const Color(0xFFE4572E),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE4572E),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
