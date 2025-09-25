import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';

class UserRepository {
  final CollectionReference _todos = FirebaseFirestore.instance.collection(
    'todos',
  );

  Future<void> addTodo(TodoModel todo) async {
    await _todos.doc(todo.id).set(todo.toJson());
  }

  Future<TodoModel?> getUser(String id) async {
    final doc = await _todos.doc(id).get();
    if (!doc.exists) return null;
    return TodoModel.fromFirestore(doc);
  }

  Stream<List<TodoModel>> getAllTodos() {
    return _todos.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> updatetodo(TodoModel todo) async {
    await _todos.doc(todo.id).update(todo.toJson());
  }

  Future<void> deleteTodo(String id) async {
    await _todos.doc(id).delete();
  }
}
