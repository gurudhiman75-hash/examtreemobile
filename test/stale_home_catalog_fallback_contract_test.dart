import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home falls back to the live catalogue when admin selections are stale', () {
    final source =
        File('lib/features/home/presentation/home_screen_v8.dart').readAsStringSync();

    expect(source, contains('final resolvedConfigured = orderedCodes'));
    expect(source, contains('if (resolvedConfigured.isNotEmpty)'));
    expect(
      source,
      contains('return catalog.categories'),
      reason:
          'Stale exam-family selections must fall back to current backend categories.',
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
