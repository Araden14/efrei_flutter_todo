import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo/repositories/todo.repository.dart';
import '../../models/Todo/todo.model.dart';

class TodoService {
  final todoRepository = TodoRepository();

  // Add a new todo
  Future<String> addTodo(TodoModel todo) async {
    try {
      final String newTodoId = await todoRepository.addTodo(todo);
      return newTodoId;
    } catch (e) {
      //popup erreur $e
      return '$e';
    }
  }

  // Fetch all todos (stream for real-time updates)
  Stream<List<TodoModel>> getTodosStream() {
    try {
      return todoRepository.getAllTodos();
    } catch (e) {
      // popup erreur $e
      return Stream.empty();
    }
  }

  // Update a todo (e.g., toggle completed)
  Future<void> updateTodo(String id, Map<String, dynamic> updates) async {
    try {
      return todoRepository.updateTodo(id, updates);
    } catch ($e) {
      //popup erreur $e
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    todoRepository.deleteTodo(id);
  }
}
