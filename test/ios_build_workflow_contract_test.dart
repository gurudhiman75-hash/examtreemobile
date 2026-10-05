import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS build verification stays manual and reproducible', () {
    final workflow = File(
      '.github/workflows/verify-ios-build.yml',
    ).readAsStringSync();

    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, isNot(contains('pull_request:')));
    expect(workflow, isNot(contains('push:')));
    expect(workflow, contains('runs-on: macos-15'));
    expect(workflow, contains("flutter-version: '3.47.0'"));
    expect(workflow, contains('xcodebuild -version'));
    expect(workflow, contains('plutil -lint ios/Runner/Info.plist'));
    expect(workflow, contains('plutil -lint ios/Runner/Runner.entitlements'));
    expect(workflow, contains('flutter build ios --simulator --debug'));
    expect(workflow, contains('build/ios/iphonesimulator/Runner.app'));
  });
}
