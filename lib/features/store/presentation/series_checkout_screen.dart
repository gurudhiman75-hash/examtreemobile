import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../home/presentation/mobile_test_series_detail_screen.dart';
import '../data/store_repository.dart';
import '../domain/series_purchase.dart';
import 'providers/store_providers.dart';
import 'series_purchase_shared.dart';
import '../../../l10n/l10n.dart';

final checkoutCouponQuoteProvider =
    FutureProvider.family<CouponQuote, ({String productId, String code})>(
  (ref, key) => ref.watch(storeRepositoryProvider).validateCoupon(
        productId: key.productId,
        couponCode: key.code,
      ),
);

class SeriesCheckoutScreen extends ConsumerStatefulWidget {
  const SeriesCheckoutScreen({
    super.key,
    required this.seriesId,
    required this.productId,
    this.couponCode,
  });

  final String seriesId;
  final String productId;
  final String? couponCode;

  @override
  ConsumerState<SeriesCheckoutScreen> createState() =>
      _SeriesCheckoutScreenState();
}

class _SeriesCheckoutScreenState extends ConsumerState<SeriesCheckoutScreen> {
  late final Razorpay _razorpay;
  late final String _idempotencyKey;
  CheckoutOrder? _order;
  String? _paymentId;
  String? _signature;
  bool _opening = false;
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final entropy = Random.secure().nextInt(1 << 31);
    _idempotencyKey = 'mobile-' +
        widget.productId +
        '-' +
        DateTime.now().microsecondsSinceEpoch.toString() +
        '-' +
        entropy.toString();

    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentFailure)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _openPayment(SeriesPurchasePlan plan) async {
    if (_opening || _confirming) return;
    setState(() {
      _opening = true;
      _error = null;
    });

    try {
      final order = await ref.read(storeRepositoryProvider).createOrder(
            productId: plan.id,
            idempotencyKey: _idempotencyKey,
            couponCode: widget.couponCode,
          );
      _order = order;
      final user = FirebaseAuth.instance.currentUser;
      final options = <String, dynamic>{
        'key': order.keyId,
        'amount': order.amountMinor,
        'currency': order.currency,
        'name': 'Examtree',
        'description': plan.title,
        'order_id': order.providerOrderId,
        'retry': {'enabled': true, 'max_count': 2},
        'theme': {'color': '#0B5D96'},
        'prefill': {
          if ((user?.email ?? '').trim().isNotEmpty)
            'email': user!.email!.trim(),
          if ((user?.phoneNumber ?? '').trim().isNotEmpty)
            'contact': user!.phoneNumber!.trim(),
        },
      };
      _razorpay.open(options);
    } on StoreCatalogException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.storeOpenPaymentFailed);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    final paymentId = response.paymentId?.trim() ?? '';
    final signature = response.signature?.trim() ?? '';
    if (paymentId.isEmpty || signature.isEmpty || _order == null) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.storeIncompleteConfirmation;
      });
      return;
    }
    _paymentId = paymentId;
    _signature = signature;
    unawaited(_confirmPayment());
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _error = response.message?.trim().isNotEmpty == true
          ? response.message!.trim()
          : context.l10n.storePaymentNotCompleted;
    });
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    final wallet = response.walletName?.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wallet == null || wallet.isEmpty
              ? context.l10n.storeContinueWallet
              : context.l10n.storeContinueInWallet(wallet),
        ),
      ),
    );
  }

  Future<void> _confirmPayment() async {
    final order = _order;
    final paymentId = _paymentId;
    final signature = _signature;
    if (order == null ||
        paymentId == null ||
        signature == null ||
        _confirming) {
      return;
    }

    setState(() {
      _confirming = true;
      _error = null;
    });

    try {
      PaymentConfirmation? result;
      for (var attempt = 0; attempt < 6; attempt++) {
        result = await ref.read(storeRepositoryProvider).confirmOrder(
              orderId: order.orderId,
              providerPaymentId: paymentId,
              providerSignature: signature,
            );
        if (result.ok && result.orderStatus.toLowerCase() == 'paid') break;
        if (!result.pending) break;
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }

      if (!mounted) return;
      if (result?.ok == true && result!.orderStatus.toLowerCase() == 'paid') {
        ref
          ..invalidate(mobileTestSeriesDetailProvider(widget.seriesId))
          ..invalidate(storeProductsProvider);
        context.go(
          Uri(
            path: '/payment-success',
            queryParameters: {
              'seriesId': widget.seriesId,
              'orderId': order.orderId,
              'orderNumber': order.orderNumber,
            },
          ).toString(),
        );
      } else {
        setState(() {
          _error =
              context.l10n.storeActivationProcessing;
        });
      }
    } on StoreCatalogException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(mobileTestSeriesDetailProvider(widget.seriesId));

    return Scaffold(
      backgroundColor: purchasePage,
      appBar: purchaseAppBar(context.l10n.storeCheckout),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => PurchaseState(
          icon: Icons.cloud_off_outlined,
          title: context.l10n.storeCheckoutFailed,
          action: context.l10n.retry,
          onAction: () =>
              ref.invalidate(mobileTestSeriesDetailProvider(widget.seriesId)),
        ),
        data: (body) {
          final info = seriesInfo(body);
          final commerce = SeriesCommerceState.fromBody(body);
          SeriesPurchasePlan? selected;
          for (final plan in commerce.plans) {
            if (plan.id == widget.productId) {
              selected = plan;
              break;
            }
          }

          if (commerce.hasFullAccess) {
            return PurchaseState(
              icon: Icons.verified_rounded,
              iconColor: const Color(0xFF10996F),
              title: context.l10n.storeAlreadyActive,
              action: context.l10n.storeOpenTestSeries,
              onAction: () => context.go(
                '/test-series?id=' + Uri.encodeQueryComponent(widget.seriesId),
              ),
            );
          }
          if (selected == null) {
            return PurchaseState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.storePlanUnavailable,
            );
          }

          final plan = selected;
          final coupon = widget.couponCode?.trim().toUpperCase() ?? '';
          final quoteAsync = coupon.isEmpty
              ? null
              : ref.watch(
                  checkoutCouponQuoteProvider(
                    (productId: plan.id, code: coupon),
                  ),
                );
          final quote = quoteAsync?.value;
          final quoteLoading = quoteAsync?.isLoading == true;
          final quoteError = quoteAsync?.hasError == true;
          final payable = quote?.totalMinor ?? plan.salePriceMinor;

          if (_confirming) return const _PaymentProcessing();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            children: [
              PurchaseHero(
                eyebrow: info.examName,
                title: context.l10n.storeReviewPay,
                subtitle: info.name,
              ),
              const SizedBox(height: 16),
              _OrderSummary(
                seriesName: info.name,
                plan: plan,
                quote: quote,
              ),
              const SizedBox(height: 14),
              const _PaymentMethod(),
              if (coupon.isNotEmpty) ...[
                const SizedBox(height: 12),
                if (quoteLoading)
                  const LinearProgressIndicator(minHeight: 3)
                else if (quoteError)
                  InlinePurchaseWarning(
                    context.l10n.storeCouponRevalidate,
                  )
                else if (quote != null)
                  _CouponApplied(quote: quote),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                InlinePurchaseWarning(_error!),
              ],
              const SizedBox(height: 14),
              const SecurePaymentNote(),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: quoteLoading || quoteError
                    ? null
                    : (_paymentId != null && _signature != null
                        ? _confirmPayment
                        : () => _openPayment(plan)),
                style: FilledButton.styleFrom(
                  backgroundColor: purchaseBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _opening
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _paymentId != null && _signature != null
                            ? context.l10n.storeVerifyPayment
                            : context.l10n.storePayAmount(
                                formatSeriesMoney(payable, plan.currency),
                              ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.seriesName,
    required this.plan,
    required this.quote,
  });

  final String seriesName;
  final SeriesPurchasePlan plan;
  final CouponQuote? quote;

  @override
  Widget build(BuildContext context) {
    final total = quote?.totalMinor ?? plan.salePriceMinor;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: purchaseCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.storeOrderSummary,
            style: TextStyle(
              color: Color(0xFF10264A),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            seriesName,
            style: const TextStyle(
              color: Color(0xFF10264A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            context.l10n.storeAccess(validityLabel(context, plan.validityDays)),
            style: const TextStyle(color: purchaseMuted, fontSize: 12),
          ),
          const Divider(height: 24, color: purchaseLine),
          ReceiptRow(
            label: context.l10n.storePlanPrice,
            value: formatSeriesMoney(plan.salePriceMinor, plan.currency),
          ),
          if (quote != null && quote!.discountMinor > 0) ...[
            const SizedBox(height: 9),
            ReceiptRow(
              label: context.l10n.storeCouponDiscount,
              value: '-' +
                  formatSeriesMoney(
                    quote!.discountMinor,
                    quote!.currency,
                  ),
              valueColor: const Color(0xFF10996F),
            ),
          ],
          const Divider(height: 24, color: purchaseLine),
          ReceiptRow(
            label: context.l10n.storeTotalPayable,
            value: formatSeriesMoney(total, plan.currency),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: purchaseCardDecoration(),
      child: Row(
        children: [
          _PaymentIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.storeUpiCards,
                  style: TextStyle(
                    color: Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  context.l10n.storeRazorpayBody,
                  style: TextStyle(
                    color: purchaseMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF10996F),
          ),
        ],
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.payments_outlined,
        color: Color(0xFF176CC0),
      ),
    );
  }
}

class _CouponApplied extends StatelessWidget {
  const _CouponApplied({required this.quote});
  final CouponQuote quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: Color(0xFF10996F),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quote.couponCode +
                  ' applied • You save ' +
                  formatSeriesMoney(
                    quote.discountMinor,
                    quote.currency,
                  ),
              style: const TextStyle(
                color: Color(0xFF087653),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentProcessing extends StatelessWidget {
  const _PaymentProcessing();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            SizedBox(height: 18),
            Text(
              context.l10n.storeActivating,
              style: TextStyle(
                color: Color(0xFF10264A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              context.l10n.storeKeepOpen,
              textAlign: TextAlign.center,
              style: TextStyle(color: purchaseMuted),
            ),
          ],
        ),
      ),
    );
  }
}
