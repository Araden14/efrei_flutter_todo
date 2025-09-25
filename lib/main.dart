import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/home.dart';
import 'dart:developer' as developer;
import 'package:flutter_todo/env/firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Starting app initialization...'); // Health check: App start
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully.'); // Health check: Firebase ready
  } catch (e) {
    developer.log('Firebase initialization failed: $e'); // Health check: Firebase error
  }
  developer.log('Running app...'); // Health check: App launch
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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