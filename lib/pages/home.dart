import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add a todo'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add_todo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _signOut,
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "✌️MegaTODO+",
          style: TextStyle(
            fontSize: 24,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            wordSpacing: 4.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: const TodoList(),
            ),
          ],
        ),
      ),
    );
  }
}

