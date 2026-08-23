import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS registers the canonical ExamTree deep-link scheme', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(infoPlist, contains('<key>CFBundleURLTypes</key>'));
    expect(infoPlist, contains('<key>CFBundleURLSchemes</key>'));
    expect(infoPlist, contains('<string>examtree</string>'));
    expect(infoPlist, contains('<string>com.examtree.examtree</string>'));
  });
}
