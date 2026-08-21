import 'package:examtree/features/store/domain/store_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreProduct.fromJson', () {
    test('parses the canonical commerce product contract', () {
      final product = StoreProduct.fromJson({
        'id': '3d06a5ff-f6a2-4f8d-8db7-8f3cd4b3e7c5',
        'code': 'SSC-CGL-01',
        'title': 'SSC CGL Test Series',
        'description': 'Full-length practice tests',
        'currency': 'inr',
        'listPriceMinor': 69900,
        'salePriceMinor': 49900,
        'validityDays': 180,
        'saleStartAt': '2026-08-20T00:00:00.000Z',
        'saleEndAt': '2026-09-20T00:00:00.000Z',
        'testCount': 25,
      });

      expect(product.code, 'SSC-CGL-01');
      expect(product.title, 'SSC CGL Test Series');
      expect(product.currency, 'INR');
      expect(product.listPriceMinor, 69900);
      expect(product.salePriceMinor, 49900);
      expect(product.validityDays, 180);
      expect(product.testCount, 25);
      expect(product.hasCanonicalDiscount, isTrue);
      expect(product.saleStartAt?.isUtc, isTrue);
      expect(product.saleEndAt?.isUtc, isTrue);
    });

    test('keeps optional catalogue metadata optional', () {
      final product = StoreProduct.fromJson({
        'id': '3d06a5ff-f6a2-4f8d-8db7-8f3cd4b3e7c5',
        'code': 'FREE-01',
        'title': 'Starter Tests',
        'description': null,
        'currency': 'INR',
        'listPriceMinor': 0,
        'salePriceMinor': 0,
      });

      expect(product.description, isEmpty);
      expect(product.validityDays, isNull);
      expect(product.testCount, 0);
      expect(product.hasCanonicalDiscount, isFalse);
    });

    test('rejects malformed price data', () {
      expect(
        () => StoreProduct.fromJson({
          'id': '3d06a5ff-f6a2-4f8d-8db7-8f3cd4b3e7c5',
          'title': 'Broken product',
          'currency': 'INR',
          'listPriceMinor': -1,
          'salePriceMinor': 100,
        }),
        throwsFormatException,
      );
    });

    test('rejects products without a title', () {
      expect(
        () => StoreProduct.fromJson({
          'id': '3d06a5ff-f6a2-4f8d-8db7-8f3cd4b3e7c5',
          'currency': 'INR',
          'listPriceMinor': 100,
          'salePriceMinor': 100,
        }),
        throwsFormatException,
      );
    });
  });
}
