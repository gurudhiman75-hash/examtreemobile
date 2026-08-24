import 'dart:io';

import 'package:examtree/features/auth/domain/google_sign_in_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google OAuth client ID validation accepts only configured client IDs', () {
    expect(
      isGoogleOAuthClientId('123-example.apps.googleusercontent.com'),
      isTrue,
    );
    expect(isGoogleOAuthClientId(''), isFalse);
    expect(isGoogleOAuthClientId('not-an-oauth-client'), isFalse);
  });

  test('iOS Google configuration is explicit and fail-closed', () {
    final config = File(
      'lib/features/auth/domain/google_sign_in_config.dart',
    ).readAsStringSync();
    final gateway = File(
      'lib/features/auth/presentation/providers/auth_providers.dart',
    ).readAsStringSync();

    expect(
      config,
      contains(
        "const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');",
      ),
    );
    expect(
      config,
      isNot(contains("'GOOGLE_IOS_CLIENT_ID',\n  defaultValue:")),
    );
    expect(gateway, contains('defaultTargetPlatform == TargetPlatform.iOS'));
    expect(gateway, contains('!isGoogleIosSignInConfigured'));
    expect(
      gateway,
      contains('clientId: requiresIosClientId ? googleIosClientId : null'),
    );
    expect(gateway, contains('serverClientId: googleServerClientId'));
  });
}
