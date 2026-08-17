import 'package:examtree/core/network/api_server_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('apiHealthUriForBase', () {
    test('targets the root health route from the production API base', () {
      final health = apiHealthUriForBase(
        'https://examtree-new.onrender.com/api',
      );

      expect(health.toString(), 'https://examtree-new.onrender.com/health');
    });

    test('preserves a development host and explicit port', () {
      final health = apiHealthUriForBase('http://127.0.0.1:3001/api');

      expect(health.toString(), 'http://127.0.0.1:3001/health');
    });

    test('rejects a relative API base', () {
      expect(
        () => apiHealthUriForBase('/api'),
        throwsArgumentError,
      );
    });
  });
}
