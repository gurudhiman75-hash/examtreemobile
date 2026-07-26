import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/providers/repository_providers.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

abstract interface class AuthSessionGateway {
  Future<void> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();
}

class FirebaseAuthSessionGateway implements AuthSessionGateway {
  const FirebaseAuthSessionGateway(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Firebase sign-in did not return a user.',
      );
    }

    try {
      await user.getIdToken(true);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

abstract interface class StudentProfileProvisioner {
  Future<void> provision();
}

class ApiStudentProfileProvisioner implements StudentProfileProvisioner {
  const ApiStudentProfileProvisioner(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> provision() async {
    await _apiClient.dio.get<Map<String, dynamic>>('/users/me');
  }
}

class AuthProfileSyncException implements Exception {
  const AuthProfileSyncException({
    this.message = 'Unable to prepare your ExamTree student profile.',
  });

  final String message;

  @override
  String toString() => message;
}

class AuthController {
  const AuthController(this._sessionGateway, this._profileProvisioner);

  final AuthSessionGateway _sessionGateway;
  final StudentProfileProvisioner _profileProvisioner;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _sessionGateway.signInWithEmailAndPassword(email, password);

    try {
      await _profileProvisioner.provision();
    } catch (_) {
      try {
        await _sessionGateway.signOut();
      } catch (_) {
        // Preserve the canonical provisioning failure as the user-facing error.
      }
      throw const AuthProfileSyncException();
    }
  }

  Future<void> signOut() => _sessionGateway.signOut();
}

final authSessionGatewayProvider = Provider<AuthSessionGateway>((ref) {
  return FirebaseAuthSessionGateway(ref.watch(firebaseAuthProvider));
});

final studentProfileProvisionerProvider = Provider<StudentProfileProvisioner>((
  ref,
) {
  return ApiStudentProfileProvisioner(ref.watch(apiClientProvider));
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    ref.watch(authSessionGatewayProvider),
    ref.watch(studentProfileProvisionerProvider),
  );
});
