import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/google_sign_in_config.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthEmailVerificationRequiredException implements Exception {
  const AuthEmailVerificationRequiredException(this.email);

  final String email;

  String get message => email.trim().isEmpty
      ? 'Verify your email address before signing in to ExamTree. A verification link has been sent.'
      : 'Verify $email before signing in to ExamTree. A verification link has been sent.';

  @override
  String toString() => message;
}

abstract interface class AuthSessionGateway {
  Future<void> signInWithEmailAndPassword(String email, String password);

  Future<void> signInWithGoogle();

  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

class FirebaseAuthSessionGateway implements AuthSessionGateway {
  FirebaseAuthSessionGateway(
    this._auth, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  Future<void> _ensureGoogleInitialized() {
    if (!isGoogleSignInConfigured) {
      throw FirebaseAuthException(
        code: 'google-sign-in-not-configured',
        message: 'Google Sign-In is not configured for this ExamTree build.',
      );
    }

    return _googleInitialization ??= _googleSignIn.initialize(
      serverClientId: googleServerClientId,
    );
  }

  Future<User> _reloadCurrentUser(User user) async {
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Firebase sign-in did not return a user.',
      );
    }
    return refreshed;
  }

  Future<void> _requireVerifiedPasswordEmail(User user) async {
    final refreshed = await _reloadCurrentUser(user);
    if (refreshed.emailVerified) {
      await refreshed.getIdToken(true);
      return;
    }

    try {
      await refreshed.sendEmailVerification();
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }

    final email = refreshed.email?.trim() ?? '';
    await _auth.signOut();
    throw AuthEmailVerificationRequiredException(email);
  }

  Future<void> _requireVerifiedGoogleEmail(User user) async {
    final refreshed = await _reloadCurrentUser(user);
    if (!refreshed.emailVerified) {
      await _auth.signOut();
      await _signOutGoogleIfInitialized();
      throw FirebaseAuthException(
        code: 'google-email-unverified',
        message: 'Google did not provide a verified email address.',
      );
    }
    await refreshed.getIdToken(true);
  }

  Future<void> _signOutGoogleIfInitialized() async {
    final initialization = _googleInitialization;
    if (initialization == null) return;
    try {
      await initialization;
      await _googleSignIn.signOut();
    } catch (_) {
      // Firebase remains the canonical app session. Google cleanup is best-effort.
    }
  }

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
      await _requireVerifiedPasswordEmail(user);
    } on AuthEmailVerificationRequiredException {
      rethrow;
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unsupported',
        message: 'Google Sign-In is not supported on this device.',
      );
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuthentication = googleUser.authentication;
    final idToken = googleAuthentication.idToken;
    if (idToken == null || idToken.trim().isEmpty) {
      await _signOutGoogleIfInitialized();
      throw FirebaseAuthException(
        code: 'google-id-token-missing',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    try {
      final firebaseCredential = GoogleAuthProvider.credential(idToken: idToken);
      final credential = await _auth.signInWithCredential(firebaseCredential);
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'missing-user',
          message: 'Firebase Google sign-in did not return a user.',
        );
      }
      await _requireVerifiedGoogleEmail(user);
    } catch (_) {
      await _auth.signOut();
      await _signOutGoogleIfInitialized();
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
      await _requireVerifiedPasswordEmail(user);
    } on AuthEmailVerificationRequiredException {
      rethrow;
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
  Future<void> signOut() async {
    await _auth.signOut();
    await _signOutGoogleIfInitialized();
  }
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

  Future<void> signInWithGoogle() async {
    await _sessionGateway.signInWithGoogle();
    await _provisionProfile(
      failureMessage:
          'Google sign-in succeeded, but ExamTree could not finish account setup. Please try again.',
    );
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
