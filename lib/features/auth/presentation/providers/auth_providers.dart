import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthProfileSyncException implements Exception {
  const AuthProfileSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthController {
  const AuthController(this._auth, this._apiClient);

  final FirebaseAuth _auth;
  final ApiClient _apiClient;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      await _auth.signOut();
      throw const AuthProfileSyncException('Firebase sign-in did not return a user.');
    }

    try {
      // GET /users/me is the canonical first-login provisioning contract. It
      // creates or refreshes the identity, student profile and Firebase link.
      await user.getIdToken(true);
      await _apiClient.dio.get<Map<String, dynamic>>('/users/me');
    } catch (error) {
      await _auth.signOut();
      throw AuthProfileSyncException(
        'Unable to prepare your ExamTree student profile: $error',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    ref.watch(firebaseAuthProvider),
    ApiClient(),
  );
});
