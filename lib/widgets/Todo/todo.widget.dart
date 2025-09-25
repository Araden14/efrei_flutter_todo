import 'package:flutter/material.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';
import 'package:flutter_todo/repositories/Todo/todo.repository.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoRepository _todoRepo = TodoRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Todos')),
      body: StreamBuilder<List<TodoModel>>(
        stream: _todoRepo.getAllTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final todos = snapshot.data ?? [];
          if (todos.isEmpty) {
            return const Center(child: Text('No todos yet'));
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                leading: Checkbox(
                  value: todo.done,
                  onChanged: (value) async {
                    final updatedTodo = TodoModel(id: todo.id, title: todo.title, description: todo.description, done: value ?? false);//todo: factoriser dans un service
                    await _todoRepo.updateTodo(updatedTodo);
                  },
                ),
                title: Text(
                  todo.title,
                  style: todo.done
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        )
                      : null,
                ),
                subtitle: Text(todo.description)
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = TodoModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: "New Todo",
            description: "Created at ${DateTime.now()}",
            done: false,
          );
          await _todoRepo.addTodo(newTodo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
