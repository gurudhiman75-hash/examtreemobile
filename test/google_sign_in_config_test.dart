import 'package:examtree/features/auth/domain/google_sign_in_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google server client ID is configured for sarbedutech', () {
    expect(isGoogleSignInConfigured, isTrue);
    expect(googleServerClientId, startsWith('1083299267005-'));
    expect(
      googleServerClientId,
      endsWith('.apps.googleusercontent.com'),
    );
  });
}
