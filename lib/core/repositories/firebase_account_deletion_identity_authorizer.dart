import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'account_repository.dart';

class FirebaseAccountDeletionIdentityAuthorizer
    implements AccountDeletionIdentityAuthorizer {
  const FirebaseAccountDeletionIdentityAuthorizer(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<void> authorizeDeletion() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'account-deletion-no-user',
        message: 'A signed-in user is required before deleting an account.',
      );
    }

    final hasAppleProvider = user.providerData.any(
      (provider) => provider.providerId == 'apple.com',
    );
    if (!hasAppleProvider) return;

    if (kIsWeb) {
      throw FirebaseAuthException(
        code: 'apple-account-deletion-unsupported',
        message:
            'Apple account deletion authorization is unavailable on web in this mobile build.',
      );
    }

    final credential = await user.reauthenticateWithProvider(
      AppleAuthProvider(),
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final authorizationCode =
          credential.additionalUserInfo?.authorizationCode?.trim();
      if (authorizationCode == null || authorizationCode.isEmpty) {
        throw FirebaseAuthException(
          code: 'apple-authorization-code-missing',
          message:
              'Apple did not return the authorization code required for account deletion.',
        );
      }
      await _auth.revokeTokenWithAuthorizationCode(authorizationCode);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final accessToken = credential.credential?.accessToken?.trim();
      if (accessToken == null || accessToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'apple-access-token-missing',
          message:
              'Apple did not return the access token required for account deletion.',
        );
      }
      await _auth.revokeAccessToken(accessToken);
    } else {
      throw FirebaseAuthException(
        code: 'apple-account-deletion-unsupported',
        message:
            'Apple account deletion authorization is unavailable on this platform.',
      );
    }

    // Ensure the canonical DELETE /users/me request receives a token carrying
    // the fresh auth_time produced by the reauthentication above.
    await user.getIdToken(true);
  }
}
