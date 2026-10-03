class SeriesPurchasePlan {
  const SeriesPurchasePlan({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.currency,
    required this.listPriceMinor,
    required this.salePriceMinor,
    required this.validityDays,
    required this.seriesCoveredTestCount,
    required this.productTestCount,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final String currency;
  final int listPriceMinor;
  final int salePriceMinor;
  final int? validityDays;
  final int seriesCoveredTestCount;
  final int productTestCount;

  bool get hasDiscount =>
      listPriceMinor > salePriceMinor && salePriceMinor >= 0;

  int get discountPercent {
    if (!hasDiscount || listPriceMinor <= 0) return 0;
    return (((listPriceMinor - salePriceMinor) * 100) / listPriceMinor).round();
  }

  factory SeriesPurchasePlan.fromJson(Map<String, dynamic> json) {
    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    final validity = json['validityDays'];
    return SeriesPurchasePlan(
      id: json['id']?.toString().trim() ?? '',
      code: json['code']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? 'Test Series Plan',
      description: json['description']?.toString().trim() ?? '',
      currency: (json['currency']?.toString().trim().isNotEmpty == true
              ? json['currency'].toString().trim()
              : 'INR')
          .toUpperCase(),
      listPriceMinor: number(json['listPriceMinor']),
      salePriceMinor: number(json['salePriceMinor']),
      validityDays:
          validity == null ? null : number(validity),
      seriesCoveredTestCount: number(json['seriesCoveredTestCount']),
      productTestCount: number(json['productTestCount']),
    );
  }
}

class SeriesCommerceState {
  const SeriesCommerceState({
    required this.hasFullAccess,
    required this.accessRequired,
    required this.premiumTestCount,
    required this.entitledPremiumTestCount,
    required this.freeTestCount,
    required this.plans,
  });

  final bool hasFullAccess;
  final bool accessRequired;
  final int premiumTestCount;
  final int entitledPremiumTestCount;
  final int freeTestCount;
  final List<SeriesPurchasePlan> plans;

  factory SeriesCommerceState.fromBody(Map<String, dynamic> body) {
    final raw = body['commerce'];
    final commerce = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};
    final rawPlans = commerce['plans'];
    final plans = rawPlans is List
        ? rawPlans
            .whereType<Map>()
            .map((item) => SeriesPurchasePlan.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .where((item) => item.id.isNotEmpty)
            .toList(growable: false)
        : const <SeriesPurchasePlan>[];

    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    return SeriesCommerceState(
      hasFullAccess: commerce['hasFullAccess'] == true,
      accessRequired: commerce['accessRequired'] == true,
      premiumTestCount: number(commerce['premiumTestCount']),
      entitledPremiumTestCount: number(commerce['entitledPremiumTestCount']),
      freeTestCount: number(commerce['freeTestCount']),
      plans: plans,
    );
  }
}

class CouponQuote {
  const CouponQuote({
    required this.couponCode,
    required this.discountMinor,
    required this.totalMinor,
    required this.currency,
  });

  final String couponCode;
  final int discountMinor;
  final int totalMinor;
  final String currency;

  factory CouponQuote.fromJson(Map<String, dynamic> json) {
    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    return CouponQuote(
      couponCode: json['couponCode']?.toString().trim() ?? '',
      discountMinor: number(json['discountMinor']),
      totalMinor: number(json['totalMinor']),
      currency: (json['currency']?.toString().trim() ?? 'INR').toUpperCase(),
    );
  }
}

class CheckoutOrder {
  const CheckoutOrder({
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

  factory CheckoutOrder.fromJson(Map<String, dynamic> json) {
    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    return CheckoutOrder(
      orderId: json['orderId']?.toString().trim() ?? '',
      orderNumber: json['orderNumber']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      amountMinor: number(json['amountMinor']),
      discountMinor: number(json['discountMinor']),
      currency: (json['currency']?.toString().trim() ?? 'INR').toUpperCase(),
      provider: json['provider']?.toString().trim() ?? '',
      providerOrderId: json['providerOrderId']?.toString().trim() ?? '',
      keyId: json['keyId']?.toString().trim() ?? '',
    );
  }
}

class PaymentConfirmation {
  const PaymentConfirmation({
    required this.ok,
    required this.orderId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.pending,
  });

  final bool ok;
  final String orderId;
  final String orderStatus;
  final String paymentStatus;
  final bool pending;

  factory PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmation(
      ok: json['ok'] == true,
      orderId: json['orderId']?.toString().trim() ?? '',
      orderStatus: json['orderStatus']?.toString().trim() ?? '',
      paymentStatus: json['paymentStatus']?.toString().trim() ?? '',
      pending: json['pending'] == true,
    );
  }
}
