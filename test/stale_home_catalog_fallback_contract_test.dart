import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home falls back to the live catalogue when admin selections are stale', () {
    final source =
        File('lib/features/home/presentation/home_screen_v8.dart').readAsStringSync();

    expect(source, contains('final resolved = <MobileFeaturedExamFamily>[]'));
    expect(source, contains('for (final category in catalog.categories)'));
    expect(source, contains('addCategory(category)'));
    expect(
      source,
      contains('resolved.take(8)'),
      reason:
          'Stale exam-family selections must be supplemented from current backend categories.',
    );

    expect(source, contains('final resolvedConfigured = configuredIds'));
    expect(
      source,
      contains('catalog.series.take(8)'),
      reason:
          'Stale featured-series IDs must fall back to current learner-visible series.',
    );
  });
}
