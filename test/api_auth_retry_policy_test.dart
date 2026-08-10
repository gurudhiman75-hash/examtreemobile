import 'package:examtree/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldRetryAuthentication', () {
    test('retries the first 401 for an authenticated user', () {
      expect(
        shouldRetryAuthentication(
          statusCode: 401,
          alreadyRetried: false,
          hasAuthenticatedUser: true,
        ),
        isTrue,
      );
    });

    test('never retries the same rejected request twice', () {
      expect(
        shouldRetryAuthentication(
          statusCode: 401,
          alreadyRetried: true,
          hasAuthenticatedUser: true,
        ),
        isFalse,
      );
    });

    test('does not refresh tokens for anonymous requests', () {
      expect(
        shouldRetryAuthentication(
          statusCode: 401,
          alreadyRetried: false,
          hasAuthenticatedUser: false,
        ),
        isFalse,
      );
    });

    test('does not treat server or network failures as auth expiry', () {
      for (final status in [null, 400, 403, 404, 429, 500, 503]) {
        expect(
          shouldRetryAuthentication(
            statusCode: status,
            alreadyRetried: false,
            hasAuthenticatedUser: true,
          ),
          isFalse,
        );
      }
    });
  });
}
