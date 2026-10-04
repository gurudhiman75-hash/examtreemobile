import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/presentation/mobile_test_series_detail_screen.dart';
import '../domain/series_purchase.dart';
import 'series_purchase_shared.dart';

class SeriesRenewalScreen extends ConsumerStatefulWidget {
  const SeriesRenewalScreen({super.key, required this.seriesId});
  final String seriesId;
  @override
  ConsumerState<SeriesRenewalScreen> createState() => _SeriesRenewalScreenState();
}

class _SeriesRenewalScreenState extends ConsumerState<SeriesRenewalScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(mobileTestSeriesDetailProvider(widget.seriesId));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Renew Test Series', style: TextStyle(color: Color(0xFF081847), fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF8FBFF),
        foregroundColor: const Color(0xFF081847),
        surfaceTintColor: Colors.transparent,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(mobileTestSeriesDetailProvider(widget.seriesId)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
        data: (body) {
          final info = seriesInfo(body);
          final commerce = SeriesCommerceState.fromBody(body);
          if (commerce.plans.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('No renewal plan is available right now.', textAlign: TextAlign.center),
            ));
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    Text(
                      'Renew ' + info.examName,
                      style: const TextStyle(color: Color(0xFF081847), fontSize: 27, height: 1.1, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    const Text('Continue your preparation without losing momentum.', style: TextStyle(color: Color(0xFF60759B), fontSize: 15)),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4ECF6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 76, height: 76,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6A43C5), Color(0xFF0B5D96)]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 38),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(info.examName, style: const TextStyle(color: Color(0xFF081847), fontWeight: FontWeight.w900, fontSize: 17)),
                              const SizedBox(height: 3),
                              Text(info.name, style: const TextStyle(color: Color(0xFF425D89), fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(commerce.premiumTestCount.toString() + '+ premium tests', style: const TextStyle(color: Color(0xFF60759B), fontSize: 12)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFEEF6FF), borderRadius: BorderRadius.circular(18)),
                      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF2474D9)),
                        SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Your progress will be preserved', style: TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w900)),
                          SizedBox(height: 3),
                          Text('Your attempts, analytics, bookmarks and reports stay with your account after renewal.', style: TextStyle(color: Color(0xFF60759B), height: 1.35)),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    const Text('Choose your renewal plan', style: TextStyle(color: Color(0xFF081847), fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    for (var index = 0; index < commerce.plans.length; index++) ...[
                      _RenewalPlanCard(
                        plan: commerce.plans[index],
                        selected: commerce.plans[index].id == selected.id,
                        recommended: index == 1 || (commerce.plans.length == 1 && index == 0),
                        onTap: () => setState(() => _selectedId = commerce.plans[index].id),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                    const Text('Why renew?', style: TextStyle(color: Color(0xFF081847), fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    const _WhyRenew(),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: const BoxDecoration(color: Color(0xFF062E5D), borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                  child: Row(children: [
                    Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(formatSeriesMoney(selected.salePriceMinor, selected.currency), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text(selected.validityDays == null ? 'Renewed access' : selected.validityDays.toString() + ' days access · Progress preserved', style: const TextStyle(color: Color(0xFFBFD1E4), fontSize: 11)),
                    ])),
                    FilledButton(
                      onPressed: () => context.push(Uri(path: '/series-checkout', queryParameters: {
                        'seriesId': widget.seriesId, 'productId': selected.id, 'renewal': '1',
                      }).toString()),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1773F1), foregroundColor: Colors.white, minimumSize: const Size(150, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Renew Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        SizedBox(width: 7), Icon(Icons.arrow_forward_rounded),
                      ]),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RenewalPlanCard extends StatelessWidget {
  const _RenewalPlanCard({required this.plan, required this.selected, required this.recommended, required this.onTap});
  final SeriesPurchasePlan plan;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final months = plan.validityDays == null ? null : (plan.validityDays! / 30).round().clamp(1, 36);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFF1773F1) : const Color(0xFFE4ECF6), width: selected ? 1.6 : 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? const Color(0xFF1773F1) : const Color(0xFF9AA9BF)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 7, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(months == null ? plan.title : months.toString() + ' Months', style: const TextStyle(color: Color(0xFF081847), fontSize: 20, fontWeight: FontWeight.w900)),
              if (recommended) Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFE6A7), borderRadius: BorderRadius.circular(999)),
                child: const Text('Most Popular', style: TextStyle(color: Color(0xFF7B4A00), fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(height: 3),
            Text(plan.description.trim().isEmpty ? 'Renewed access to all included tests and updates' : plan.description, style: const TextStyle(color: Color(0xFF60759B), height: 1.3)),
          ])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(formatSeriesMoney(plan.salePriceMinor, plan.currency), style: const TextStyle(color: Color(0xFF081847), fontSize: 22, fontWeight: FontWeight.w900)),
            if (plan.hasDiscount) Text(formatSeriesMoney(plan.listPriceMinor, plan.currency), style: const TextStyle(color: Color(0xFF7D8EAA), decoration: TextDecoration.lineThrough)),
          ]),
        ]),
      ),
    );
  }
}

class _WhyRenew extends StatelessWidget {
  const _WhyRenew();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE4ECF6))),
    child: const Column(children: [
      _Reason(icon: Icons.bar_chart_rounded, title: 'Continue your practice', subtitle: 'Pick up from where you left off.'),
      _Reason(icon: Icons.update_rounded, title: 'Get latest updates', subtitle: 'Access new tests and latest patterns.'),
      _Reason(icon: Icons.trending_up_rounded, title: 'Keep your progress', subtitle: 'Attempts and analytics remain saved.'),
      _Reason(icon: Icons.lightbulb_outline_rounded, title: 'Detailed solutions', subtitle: 'Keep learning with step-by-step explanations.'),
    ]),
  );
}

class _Reason extends StatelessWidget {
  const _Reason({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFEEF5FF), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: const Color(0xFF1773F1))),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Color(0xFF60759B), height: 1.3)),
      ])),
    ]),
  );
}