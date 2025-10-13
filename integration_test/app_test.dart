import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_todo/main.dart' as app;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_todo/env/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and shows a widget', (WidgetTester tester) async {
    // Initialize Firebase for integration test env
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}

    app.main();
    await tester.pumpAndSettle();

    // Expect at least MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}


