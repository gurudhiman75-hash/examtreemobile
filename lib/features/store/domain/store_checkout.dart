class StoreCheckoutOrder {
  const StoreCheckoutOrder({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.amountMinor,
    required this.discountMinor,
    required this.currency,
    required this.provider,
    required this.providerOrderId,
    required this.keyId,
  });

  final String orderId;
  final String orderNumber;
  final String status;
  final int amountMinor;
  final int discountMinor;
  final String currency;
  final String provider;
  final String providerOrderId;
  final String keyId;

  factory StoreCheckoutOrder.fromJson(Map<String, dynamic> json) {
    final provider = _requiredString(json['provider'], 'provider').toLowerCase();
    if (provider != 'razorpay') {
      throw const FormatException('Unsupported payment provider');
    }

    return StoreCheckoutOrder(
      orderId: _requiredString(json['orderId'], 'orderId'),
      orderNumber: _requiredString(json['orderNumber'], 'orderNumber'),
      status: _requiredString(json['status'], 'status'),
      amountMinor: _requiredNonNegativeInt(json['amountMinor'], 'amountMinor'),
      discountMinor: _requiredNonNegativeInt(
        json['discountMinor'] ?? 0,
        'discountMinor',
      ),
      currency: _requiredString(json['currency'], 'currency').toUpperCase(),
      provider: provider,
      providerOrderId: _requiredString(
        json['providerOrderId'],
        'providerOrderId',
      ),
      keyId: _requiredString(json['keyId'], 'keyId'),
    );
  }
}

String _requiredString(Object? value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) throw FormatException('Missing $field');
  return text;
}

int _requiredNonNegativeInt(Object? value, String field) {
  final parsed = value is num ? value.toInt() : int.tryParse(value.toString());
  if (parsed == null || parsed < 0) throw FormatException('Invalid $field');
  return parsed;
}
