import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production API preflight verifies the mobile catalogue namespace', () {
    final script = File('tool/verify_production_api.mjs').readAsStringSync();
    final workflow = File(
      '.github/workflows/verify-production-api.yml',
    ).readAsStringSync();

    expect(script, contains("base.pathname !== '/api/'"));
    expect(script, contains("new URL('/health', base)"));
    expect(script, contains("new URL('tests', base)"));
    expect(script, contains("new URL('categories', base)"));
    expect(script, contains("new URL('subcategories', base)"));
    expect(script, contains('requireNonEmpty: true'));
    expect(workflow, contains('Verify Production API'));
    expect(
      workflow,
      contains('https://examtree-new.onrender.com/api/'),
    );
    expect(workflow, contains('node tool/verify_production_api.mjs'));
  });
}
