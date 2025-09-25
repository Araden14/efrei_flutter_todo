import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';

class UserRepository {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> addUser(TodoModel user) async {
    await _users.doc(user.id).set(user.toJson());
  }

  Future<TodoModel?> getUser(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return TodoModel.fromFirestore(doc);
  }

  Stream<List<TodoModel>> getAllUsers() {
    return _users.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> updateUser(TodoModel user) async {
    await _users.doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _users.doc(id).delete();
  }
}
