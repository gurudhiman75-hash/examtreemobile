import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Privacy and account exposes actionable production resources', () {
    final source = File(
      'lib/features/profile/presentation/account_settings_screen.dart',
    ).readAsStringSync();

    expect(source, contains("import 'package:url_launcher/url_launcher.dart';"));
    expect(source, contains("'https://sarbedutech.web.app/privacy'"));
    expect(source, contains("'https://sarbedutech.web.app/account-deletion'"));
    expect(source, contains("mode: LaunchMode.externalApplication"));
    expect(source, contains("Key('account-open-privacy-policy')"));
    expect(source, contains("Key('account-open-deletion-web')"));
    expect(source, contains("actionLabel: 'Open privacy policy'"));
    expect(source, contains("actionLabel: 'Open deletion page'"));
  });

  test('External policy launch failures stay learner-safe', () {
    final source = File(
      'lib/features/profile/presentation/account_settings_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('This page could not be opened. Please try again later.'),
    );
    expect(source, isNot(contains('error.toString()')));
    expect(source, isNot(contains(r'$error')));
  });
}
