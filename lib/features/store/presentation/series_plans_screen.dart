import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/presentation/mobile_test_series_detail_screen.dart';
import '../data/store_repository.dart';
import '../domain/series_purchase.dart';
import 'providers/store_providers.dart';
import 'series_purchase_shared.dart';

class SeriesPlansScreen extends ConsumerStatefulWidget {
  const SeriesPlansScreen({super.key, required this.seriesId});
  final String seriesId;

  @override
  ConsumerState<SeriesPlansScreen> createState() => _SeriesPlansScreenState();
}

class _SeriesPlansScreenState extends ConsumerState<SeriesPlansScreen> {
  final _coupon = TextEditingController();
  String? _selectedId;
  CouponQuote? _quote;
  String? _message;
  bool _applying = false;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _apply(SeriesPurchasePlan plan) async {
    final code = _coupon.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _message = 'Enter a coupon code first.');
      return;
    }
    setState(() {
      _applying = true;
      _message = null;
      _quote = null;
    });
    try {
      final quote = await ref.read(storeRepositoryProvider).validateCoupon(
            productId: plan.id,
            couponCode: code,
          );
      if (!mounted) return;
      setState(() {
        _quote = quote;
        _message = 'Coupon applied • Save ' +
            formatSeriesMoney(quote.discountMinor, quote.currency);
      });
    } on StoreCatalogException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(mobileTestSeriesDetailProvider(widget.seriesId));
    return Scaffold(
      backgroundColor: purchasePage,
      appBar: purchaseAppBar('Choose Plan'),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => PurchaseState(
          icon: Icons.cloud_off_outlined,
          title: 'Unable to load plans',
          action: 'Retry',
          onAction: () =>
              ref.invalidate(mobileTestSeriesDetailProvider(widget.seriesId)),
        ),
        data: (body) {
          final info = seriesInfo(body);
          final commerce = SeriesCommerceState.fromBody(body);
          if (commerce.hasFullAccess) {
            return PurchaseState(
              icon: Icons.verified_rounded,
              iconColor: const Color(0xFF10996F),
              title: 'This test series is already active.',
              action: 'Open Test Series',
              onAction: () => context.go(
                '/test-series?id=' + Uri.encodeQueryComponent(widget.seriesId),
              ),
            );
          }
          if (commerce.plans.isEmpty) {
            return const PurchaseState(
              icon: Icons.inventory_2_outlined,
              title: 'No purchase plan is available right now.',
            );
          }

          final selected = commerce.plans.firstWhere(
            (plan) => plan.id == _selectedId,
            orElse: () => commerce.plans.first,
          );
          _selectedId ??= selected.id;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    PurchaseHero(
                      eyebrow: info.examName,
                      title: info.name,
                      subtitle: commerce.premiumTestCount.toString() +
                          ' premium tests • ' +
                          commerce.freeTestCount.toString() +
                          ' free',
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose your access plan',
                      style: TextStyle(
                        color: Color(0xFF10264A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Only currently published plans are shown.',
                      style: TextStyle(color: purchaseMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    for (final plan in commerce.plans) ...[
                      _PlanCard(
                        plan: plan,
                        selected: plan.id == selected.id,
                        onTap: () => setState(() {
                          _selectedId = plan.id;
                          _quote = null;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: purchaseCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Have a coupon?',
                            style: TextStyle(
                              color: Color(0xFF10264A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _coupon,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  enabled: !_applying,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter coupon code',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed:
                                    _applying ? null : () => _apply(selected),
                                child: _applying
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Apply'),
                              ),
                            ],
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _message!,
                              style: TextStyle(
                                color: _quote == null
                                    ? const Color(0xFFC2413A)
                                    : const Color(0xFF10996F),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SecurePaymentNote(),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: purchaseNavy,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected plan',
                              style: TextStyle(
                                color: Color(0xFFAFC5DC),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              formatSeriesMoney(
                                _quote?.totalMinor ??
                                    selected.salePriceMinor,
                                selected.currency,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          final query = <String, String>{
                            'seriesId': widget.seriesId,
                            'productId': selected.id,
                            if (_quote != null)
                              'coupon': _quote!.couponCode,
                          };
                          context.push(
                            Uri(
                              path: '/series-checkout',
                              queryParameters: query,
                            ).toString(),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1687E0),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(132, 46),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });
  final SeriesPurchasePlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: BorderSide(
          color: selected ? const Color(0xFF1687E0) : purchaseLine,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? const Color(0xFF1687E0)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      validityLabel(plan.validityDays),
                      style: const TextStyle(
                        color: Color(0xFF10264A),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plan.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: purchaseMuted,
                        fontSize: 12,
                      ),
                    ),
                    if (plan.seriesCoveredTestCount > 0) ...[
                      const SizedBox(height: 5),
                      Text(
                        plan.seriesCoveredTestCount.toString() +
                            ' series tests included',
                        style: const TextStyle(
                          color: Color(0xFF10996F),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatSeriesMoney(
                      plan.salePriceMinor,
                      plan.currency,
                    ),
                    style: const TextStyle(
                      color: purchaseNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  if (plan.hasDiscount)
                    Text(
                      formatSeriesMoney(
                        plan.listPriceMinor,
                        plan.currency,
                      ),
                      style: const TextStyle(
                        color: purchaseMuted,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (plan.discountPercent > 0)
                    Text(
                      plan.discountPercent.toString() + '% OFF',
                      style: const TextStyle(
                        color: Color(0xFF10996F),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
