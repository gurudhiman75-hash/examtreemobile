import 'package:examtree/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const productionBase = 'https://examtree-new.onrender.com/api/';

  test('normalizes a pathful API base with a trailing slash', () {
    expect(
      normalizeApiBaseUrl('https://examtree-new.onrender.com/api'),
      productionBase,
    );
  });

  test('leading-slash repository paths stay inside the API namespace', () {
    for (final path in <String>[
      '/tests',
      '/categories',
      '/subcategories',
      '/users/me',
      '/attempt-sessions',
      '/attempts',
    ]) {
      final resolved = resolveApiRequestUri(
        baseUrl: productionBase,
        requestPath: path,
      );
      expect(
        resolved.path,
        startsWith('/api/'),
        reason: '$path must not escape the /api namespace',
      );
    }

    expect(
      resolveApiRequestUri(
        baseUrl: productionBase,
        requestPath: '/tests',
      ).toString(),
      'https://examtree-new.onrender.com/api/tests',
    );
  });

  test('absolute URLs remain absolute and are not rewritten', () {
    expect(
      resolveApiRequestUri(
        baseUrl: productionBase,
        requestPath: 'https://example.com/file.json',
      ).toString(),
      'https://example.com/file.json',
    );
  });

  test('rejects relative API base URLs', () {
    expect(() => normalizeApiBaseUrl('/api'), throwsArgumentError);
  });
}
