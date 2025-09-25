import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';

class TodoRepository {
  final CollectionReference _todosCollection = FirebaseFirestore.instance
      .collection('todos');

  Future<String> addTodo(TodoModel todo) async {
    try {
      final ref = await _todosCollection.add(todo.toJson());
      return ref.id; // Return the generated ID
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<TodoModel> getTodo(String id) async {
    try {
      final doc = await _todosCollection.doc(id).get();
      return TodoModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get todo: $e');
    }
  }

  //todo: changer en getUserTodos
  Stream<List<TodoModel>> getAllTodos() {
    return _todosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateTodo(String todoId, Map<String, dynamic> updates) async {
    try {
      await _todosCollection.doc(todoId).update(updates);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todosCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
