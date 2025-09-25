import 'package:flutter_todo/repositories/Todo/todo.repository.dart';
import '../../models/Todo/todo.model.dart';

class TodoService {
  final todoRepository = TodoRepository();

  // Add a new todo
  Future<String> addNew(TodoModel todo) async {
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

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    todoRepository.deleteTodo(id);
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      final Map<String, dynamic> statusUpdate = {'status': status};
      return todoRepository.updateTodo(id, statusUpdate);
    } catch ($e) {
      //popup erreur $e
    }
  }
}
