import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:developer' as developer;

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Register new user with email and password
  Future<auth.User?> registerUser(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      auth.User? user = result.user;
      return user;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  // Sign in existing user with email and password
  Future<auth.User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return credential.user;
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        developer.log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        developer.log('Wrong password provided for that user.');
      }
      developer.log('Sign in error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      developer.log('Unexpected error: $e');
      return null;
    }
  }
}
