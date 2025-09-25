import 'package:flutter_todo/models/Todo/todo.model.dart';
import 'package:flutter_todo/repositories/Todo/todo.repository.dart';

class TodoService {
  final todoRepository = TodoRepository();

  void newTodo(TodoModel newTodo) async {
    //validate todo
    try {
      await todoRepository.addTodo(newTodo);
    } catch (e) {
      print("Issue creating new todo item");
    }
  }

  void changeStatus(TodoModel todoToUpdate, bool done) async {
    try {
      final updatedTodo = TodoModel(
        id: todoToUpdate.id,
        title: todoToUpdate.title,
        description: todoToUpdate.description,
        done: done,
      );
      await todoRepository.updateTodo(updatedTodo);
    } catch (e) {
      print("Issue changing the todo item's status");
    }
  }
}
