import 'package:examtree/routes/route_extra.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readRequiredRouteId', () {
    test('returns a trimmed identifier', () {
      expect(readRequiredRouteId('  test-123  '), 'test-123');
    });

    test('rejects null, non-string and blank values', () {
      expect(readRequiredRouteId(null), isNull);
      expect(readRequiredRouteId(123), isNull);
      expect(readRequiredRouteId(''), isNull);
      expect(readRequiredRouteId('   '), isNull);
    });
  });
}
