import 'package:dio/dio.dart';
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

  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

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
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Firebase registration did not return a user.',
      );
    }

    try {
      final normalizedName = displayName.trim();
      if (normalizedName.isNotEmpty) {
        await user.updateDisplayName(normalizedName);
      }
      // Refresh after updating the profile so the canonical backend sees the
      // latest Firebase identity claims during first-login provisioning.
      await user.getIdToken(true);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
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

const _sessionEndingProfileCodes = <String>{
  'SESSION_REVOKED',
  'ACCOUNT_UNAVAILABLE',
  'ACCOUNT_SUSPENDED',
  'ACCOUNT_RECOVERY_COMPLETED',
};

bool shouldEndSessionForProfileFailure(Object error) {
  if (error is! DioException) return false;

  final data = error.response?.data;
  final code = switch (data) {
    Map<String, dynamic>() => data['code']?.toString(),
    Map() => data['code']?.toString(),
    _ => null,
  };

  return code != null && _sessionEndingProfileCodes.contains(code);
}

class AuthController {
  const AuthController(this._sessionGateway, this._profileProvisioner);

  final AuthSessionGateway _sessionGateway;
  final StudentProfileProvisioner _profileProvisioner;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _sessionGateway.signInWithEmailAndPassword(email, password);
    await _provisionProfile();
  }

  Future<void> registerWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await _sessionGateway.createUserWithEmailAndPassword(
      displayName: displayName.trim(),
      email: email.trim(),
      password: password,
    );

    await _provisionProfile(
      failureMessage:
          'Your account was created, but ExamTree could not finish setup. Please try again.',
    );
  }

  Future<void> _provisionProfile({
    String failureMessage = 'Unable to prepare your ExamTree student profile.',
  }) async {
    try {
      await _profileProvisioner.provision();
    } catch (error) {
      if (shouldEndSessionForProfileFailure(error)) {
        try {
          await _sessionGateway.signOut();
        } catch (_) {
          // Preserve the canonical profile failure as the user-facing error.
        }
      }
      throw AuthProfileSyncException(message: failureMessage);
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _sessionGateway.sendPasswordResetEmail(email.trim());
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
