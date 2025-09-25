import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';

class TodoRepository {
  final CollectionReference _todosCollection = FirebaseFirestore.instance
      .collection('todos');

  Future<String> addTodo(TodoModel todo) async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = await _todosCollection.add({...todo.toJson(), 'userid': uid});
      return ref.id; // Return the generated ID
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<TodoModel> getTodo(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final query = await _todosCollection
          .where('userId', isEqualTo: uid)
          .where(FieldPath.documentId, isEqualTo: id)
          .limit(1)
          .get();
      return TodoModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Failed to get todo: $e');
    }
  }

  Stream<List<TodoModel>> getAllTodos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _todosCollection
        .where('userId', isEqualTo: uid) // only this user’s todos
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateTodo(String todoId, Map<String, dynamic> updates) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _todosCollection.doc(todoId).update({...updates, 'userId': uid});
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      FirebaseAuth.instance.currentUser!.uid;
      await _todosCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
