import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS release metadata uses canonical ExamTree product naming', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      plist,
      contains('<key>CFBundleDisplayName</key>\n\t<string>ExamTree</string>'),
    );
    expect(
      plist,
      contains('<key>CFBundleName</key>\n\t<string>ExamTree</string>'),
    );
    expect(
      plist,
      contains(
        '<key>CFBundleIdentifier</key>\n\t<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>',
      ),
    );
    expect(plist, contains('<string>examtree</string>'));
    expect(plist, isNot(contains('<string>Examtree</string>')));
  });
}
