import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shipping exam catalogue is backend-driven with no runtime sample fallback', () {
    final repository =
        File('lib/core/repositories/api_exam_repository.dart').readAsStringSync();
    final catalogProvider = File(
      'lib/features/exams/presentation/providers/exam_catalog_providers.dart',
    ).readAsStringSync();
    final home =
        File('lib/features/home/presentation/home_screen_v8.dart').readAsStringSync();

    for (final endpoint in const ['/categories', '/subcategories', '/tests']) {
      expect(
        repository,
        contains("'$endpoint'"),
        reason: 'Exam repository must load $endpoint from the canonical API.',
      );
    }

    expect(catalogProvider, contains("'/categories'"));
    expect(catalogProvider, contains("'/subcategories'"));
    expect(catalogProvider, contains("'/test-series'"));

    expect(home, contains('ref.watch(examCatalogProvider)'));
    expect(home, contains('_resolveCanonicalHomeFamilies'));
    expect(home, contains('_resolveCanonicalHomeSeries'));

    for (final embeddedFamily in const [
      "routeFamily: 'Punjab State'",
      "routeFamily: 'SSC'",
      "routeFamily: 'Banking'",
      "routeFamily: 'Railway'",
      "routeFamily: 'Teaching'",
      "routeFamily: 'Defence'",
      "routeFamily: 'State PCS'",
      "routeFamily: 'Other Exams'",
    ]) {
      expect(
        home,
        isNot(contains(embeddedFamily)),
        reason: 'Home must not ship hard-coded exam catalogue data.',
      );
    }
  });
}
