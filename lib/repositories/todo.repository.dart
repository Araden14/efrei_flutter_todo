import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';
import 'dart:developer' as developer;

class TodoRepository {
  final CollectionReference _todosCollection = FirebaseFirestore.instance
      .collection('todos');

  Future<String> addTodo(TodoModel todo) async {
    try {
      if (todo.id == null || todo.id!.isEmpty) {
        throw ArgumentError('Todo ID must be provided (UUID from client)');
      }
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final data = todo.toJson();
      data['userId'] = uid;  // Ensure userId is set for queries/rules
      await _todosCollection.doc(todo.id!).set(data);  // Use custom ID with .set()
      return todo.id!;  // Return the client-generated ID directly
    } catch (e) {
      developer.log('Error adding todo: $e');
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
      if (query.docs.isEmpty) {
        throw Exception('Todo not found');
      }
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
      final uid = FirebaseAuth.instance.currentUser!.uid;  // Use for potential rules check
      await _todosCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}