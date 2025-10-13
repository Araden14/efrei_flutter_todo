import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/models/Todo/todo.model.dart';
import 'package:flutter_todo/repositories/todo.repository.dart';

void main() {
  group('TodoRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late TodoRepository repository;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'test-user'));
      await mockAuth.signInWithEmailAndPassword(email: 'a@b.c', password: 'pw');
      repository = TodoRepository(firestore: fakeFirestore, firebaseAuth: mockAuth);
    });

    test('add and get todo', () async {
      final todo = TodoModel(
        id: 'abc-123',
        title: 'Write tests',
        description: 'Ensure repository works',
        userId: 'test-user',
        createdAt: DateTime.now(),
      );

      final id = await repository.addTodo(todo);
      expect(id, equals('abc-123'));

      final fetched = await repository.getTodo('abc-123');
      expect(fetched.title, equals('Write tests'));
      expect(fetched.userId, equals('test-user'));
    });

    test('update and delete todo', () async {
      final todo = TodoModel(
        id: 'id-1',
        title: 'Initial',
        userId: 'test-user',
        createdAt: DateTime.now(),
      );
      await repository.addTodo(todo);

      await repository.updateTodo('id-1', {'status': 'done'});
      final updated = await repository.getTodo('id-1');
      expect(updated.status, 'done');

      await repository.deleteTodo('id-1');
      await expectLater(
        repository.getTodo('id-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}


