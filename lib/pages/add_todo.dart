import 'package:flutter/material.dart';
import '../widgets/add_todo.dart';
import '../models/Todo/todo.model.dart';

class AddTodoPage extends StatelessWidget {
  final TodoModel? todo;

  const AddTodoPage({super.key, this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todo == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TodoInput(todo: todo),
      ),
    );
  }
}