import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Runner signs with the Sign in with Apple entitlement in every config', () {
    final entitlements = File('ios/Runner/Runner.entitlements').readAsStringSync();
    final debug = File('ios/Flutter/Debug.xcconfig').readAsStringSync();
    final release = File('ios/Flutter/Release.xcconfig').readAsStringSync();

    expect(entitlements, contains('<key>com.apple.developer.applesignin</key>'));
    expect(entitlements, contains('<string>Default</string>'));
    expect(debug, contains('CODE_SIGN_ENTITLEMENTS=Runner/Runner.entitlements'));
    expect(release, contains('CODE_SIGN_ENTITLEMENTS=Runner/Runner.entitlements'));
  });

  test('Apple authentication stays native-iOS-only and uses Firebase provider', () {
    final login = File(
      'lib/features/auth/presentation/login_screen.dart',
    ).readAsStringSync();
    final providers = File(
      'lib/features/auth/presentation/providers/auth_providers.dart',
    ).readAsStringSync();

    expect(
      login,
      contains('!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS'),
    );
    expect(login, contains('showApple: showApple'));
    expect(providers, contains('AppleAuthProvider()'));
    expect(providers, contains('_auth.signInWithProvider'));
    expect(providers, contains("code: 'apple-sign-in-unsupported'"));
    expect(providers, contains("code: 'apple-email-unavailable'"));
  });
}
