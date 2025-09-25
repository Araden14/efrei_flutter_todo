import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Todo/todo.model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'todos';

  // Add a new todo
  Future<String> addTodo(TodoModel todo) async {
    try {
      final ref = await _firestore.collection(_collection).add(todo.toJson());
      return ref.id;  // Return the generated ID
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  // Fetch all todos (stream for real-time updates)
  Stream<List<TodoModel>> getTodosStream() {
    return _firestore.collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc))
            .toList());
  }

  // Update a todo (e.g., toggle completed)
  Future<void> updateTodo(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}