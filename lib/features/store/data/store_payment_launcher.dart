import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../domain/store_checkout.dart';
import '../domain/store_product.dart';

enum StorePaymentOutcome { success, cancelled, failed }

class StorePaymentResult {
  const StorePaymentResult._({
    required this.outcome,
    this.paymentId,
    this.errorCode,
  });

  const StorePaymentResult.success({String? paymentId})
      : this._(
          outcome: StorePaymentOutcome.success,
          paymentId: paymentId,
        );

  const StorePaymentResult.cancelled()
      : this._(outcome: StorePaymentOutcome.cancelled);

  const StorePaymentResult.failed({int? errorCode})
      : this._(
          outcome: StorePaymentOutcome.failed,
          errorCode: errorCode,
        );

  final StorePaymentOutcome outcome;
  final String? paymentId;
  final int? errorCode;
}

abstract interface class StorePaymentLauncher {
  Future<StorePaymentResult> open({
    required StoreCheckoutOrder order,
    required StoreProduct product,
    String? email,
  });
}

class RazorpayStorePaymentLauncher implements StorePaymentLauncher {
  @override
  Future<StorePaymentResult> open({
    required StoreCheckoutOrder order,
    required StoreProduct product,
    String? email,
  }) {
    final razorpay = Razorpay();
    final completer = Completer<StorePaymentResult>();

    void complete(StorePaymentResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) {
        complete(StorePaymentResult.success(paymentId: response.paymentId));
      },
    );
    razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) {
        if (response.code == Razorpay.PAYMENT_CANCELLED) {
          complete(const StorePaymentResult.cancelled());
          return;
        }
        complete(StorePaymentResult.failed(errorCode: response.code));
      },
    );
    razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {
        // Wallet selection is not a terminal payment state. Razorpay will emit
        // success or failure after the provider flow finishes.
      },
    );

    final trimmedEmail = email?.trim();
    final options = <String, dynamic>{
      'key': order.keyId,
      'order_id': order.providerOrderId,
      'amount': order.amountMinor,
      'currency': order.currency,
      'name': 'ExamTree',
      'description': product.title,
      if (trimmedEmail != null && trimmedEmail.isNotEmpty)
        'prefill': {'email': trimmedEmail},
    };

    try {
      razorpay.open(options);
    } catch (_) {
      complete(const StorePaymentResult.failed());
    }

    return completer.future.whenComplete(razorpay.clear);
  }
}
