import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';
import 'package:flutter_todo/repositories/todo.repository.dart';
import 'package:flutter_todo/services/todo_service.dart';

void main() {
  group('TodoService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late TodoRepository repository;
    late TodoService service;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'user-1'));
      await mockAuth.signInWithEmailAndPassword(email: 'x@y.z', password: 'pw');
      repository = TodoRepository(firestore: fakeFirestore, firebaseAuth: mockAuth);
      service = TodoService(repository: repository, firebaseAuth: mockAuth);
    });

    test('addNew returns id', () async {
      final todo = TodoModel(
        id: 't-1',
        title: 'Service Add',
        userId: 'user-1',
        createdAt: DateTime.now(),
      );
      final id = await service.addNew(todo);
      expect(id, 't-1');
    });

    test('getTodosStream emits user todos', () async {
      final t1 = TodoModel(
        id: 'a',
        title: 'A',
        userId: 'user-1',
        createdAt: DateTime.now(),
      );
      final t2 = TodoModel(
        id: 'b',
        title: 'B',
        userId: 'user-1',
        createdAt: DateTime.now(),
      );
      await repository.addTodo(t1);
      await repository.addTodo(t2);

      final first = await service.getTodosStream().first;
      expect(first.length, 2);
    });
  });
}


