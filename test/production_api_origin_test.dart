import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const productionOrigin = 'https://api.examtree.in';
  const legacyOrigin = 'https://examtree-new.onrender.com/api';

  const shippingConfigurationFiles = <String>[
    'lib/core/network/api_client.dart',
    '.github/workflows/authenticated-android-apk.yml',
    '.github/workflows/release-android-aab.yml',
    'README.md',
  ];

  test('shipping mobile configuration uses the canonical production API', () {
    for (final path in shippingConfigurationFiles) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains(productionOrigin),
        reason: '$path must reference the canonical production API origin',
      );
      expect(
        source,
        isNot(contains(legacyOrigin)),
        reason: '$path must not ship the retired Render API origin',
      );
    }
  });
}
