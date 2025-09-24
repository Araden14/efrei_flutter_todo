import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/home.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // Define the initial route
      initialRoute: '/',
      // Map route names to widgets
      routes: {
        '/': (context) => const HomePage(),  // Default/home route
      },
    );
  }
}