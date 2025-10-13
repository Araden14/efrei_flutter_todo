import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_todo/pages/home.dart';
import 'dart:developer' as developer;
import 'package:flutter_todo/env/firebase_options.dart';
import 'package:flutter_todo/pages/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_todo/pages/add_todo.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MegaTodo+',
      routerConfig: _router,
    );
  }
}

// Router configuration with authentication guard
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthGuard(child: HomePage());
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthPage();
      },
    ),
    GoRoute(
      path: '/add_todo',
      builder: (BuildContext context, GoRouterState state) {
        return const AddTodoPage();
      },
    ),
  ],
);

// Authentication guard widget
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, show the protected page
          return child;
        } else {
          // User is not authenticated, redirect to auth
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}