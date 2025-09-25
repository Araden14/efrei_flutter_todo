import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_todo/pages/home.dart';
import 'dart:developer' as developer;
import 'package:flutter_todo/env/firebase_options.dart';
import 'pages/auth.dart';

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
    final GoRouter _router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/auth',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthPage();
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      routerConfig: _router,
    );
  }
}