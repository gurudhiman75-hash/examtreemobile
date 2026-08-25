import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const productionBase = 'https://examtree-new.onrender.com/api';
  const unverifiedCustomOrigin = 'https://api.examtree.in';

  const shippingConfigurationFiles = <String>[
    'lib/core/network/api_client.dart',
    '.github/workflows/authenticated-android-apk.yml',
    '.github/workflows/release-android-aab.yml',
    'README.md',
  ];

  test('shipping mobile configuration uses the live production API base', () {
    for (final path in shippingConfigurationFiles) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains(productionBase),
        reason: '$path must reference the live production API base',
      );
    }
  });

  test('shipping build files do not use the unverified custom API hostname', () {
    for (final path in shippingConfigurationFiles.take(3)) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        isNot(contains(unverifiedCustomOrigin)),
        reason:
            '$path must not use api.examtree.in until DNS/TLS routing is verified',
      );
    }
  });
}
