import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/todo_list.dart';
import '../services/todo_service.dart';
import '../models/Todo/todo.model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final todoService = TodoService();
  late final Stream<List<TodoModel>> _todos$ = todoService.getTodosStream();


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
              child: StreamBuilder<List<TodoModel>>(
                stream: _todos$,
                builder: (BuildContext context, AsyncSnapshot<List<TodoModel>> snapshot) {
                  // snapshot = current state of the stream
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData) {
                  return const Text('No data yet');
                }
                final data = snapshot.data!;
                return TodoList(data);

              },
              ),
            )
          ],
        ),
      ),
    );
  }
}

