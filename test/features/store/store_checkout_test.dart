import 'package:examtree/features/store/domain/store_checkout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses canonical Razorpay checkout order', () {
    final order = StoreCheckoutOrder.fromJson({
      'orderId': 'ac0a95ad-f5b2-4c83-9c65-f8407fb65b63',
      'orderNumber': '1042',
      'status': 'payment_pending',
      'amountMinor': 49900,
      'discountMinor': 5000,
      'currency': 'inr',
      'provider': 'razorpay',
      'providerOrderId': 'order_Qwerty123',
      'keyId': 'rzp_test_example',
    });

    expect(order.orderNumber, '1042');
    expect(order.amountMinor, 49900);
    expect(order.discountMinor, 5000);
    expect(order.currency, 'INR');
    expect(order.providerOrderId, 'order_Qwerty123');
  });

  test('rejects checkout payload without provider order id', () {
    expect(
      () => StoreCheckoutOrder.fromJson({
        'orderId': 'ac0a95ad-f5b2-4c83-9c65-f8407fb65b63',
        'orderNumber': '1042',
        'status': 'payment_pending',
        'amountMinor': 49900,
        'currency': 'INR',
        'provider': 'razorpay',
        'keyId': 'rzp_test_example',
      }),
      throwsFormatException,
    );
  });

  test('rejects unsupported payment provider', () {
    expect(
      () => StoreCheckoutOrder.fromJson({
        'orderId': 'ac0a95ad-f5b2-4c83-9c65-f8407fb65b63',
        'orderNumber': '1042',
        'status': 'payment_pending',
        'amountMinor': 49900,
        'currency': 'INR',
        'provider': 'other',
        'providerOrderId': 'provider-order',
        'keyId': 'public-key',
      }),
      throwsFormatException,
    );
  });
}
