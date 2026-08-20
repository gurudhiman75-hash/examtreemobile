import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/promotions/domain/promotion_campaign.dart';
import 'package:examtree/features/promotions/presentation/widgets/promotion_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  PromotionCampaign campaign(String id, String title) => PromotionCampaign(
        id: id,
        title: title,
        subtitle: 'Fresh preparation material',
        placements: const {PromotionPlacement.login},
        ctaLabel: 'Explore',
        deepLink: '/learn',
      );

  Widget app(List<PromotionCampaign> campaigns, {double textScale = 1}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => Scaffold(
              body: PromotionCarousel(campaigns: campaigns, compact: true),
            )),
        GoRoute(path: '/learn', builder: (context, state) => const Scaffold(
              body: Text('Learn destination'),
            )),
      ],
    );
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    );
  }

  testWidgets('renders swipeable campaign copy and safe internal CTA', (tester) async {
    await tester.pumpWidget(app([
      campaign('one', 'Free current affairs'),
      campaign('two', 'New mock tests'),
    ]));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('promotion-carousel')), findsOneWidget);
    expect(find.text('Free current affairs'), findsOneWidget);
    expect(find.byKey(const Key('promotion-action-one')), findsOneWidget);

    await tester.tap(find.byKey(const Key('promotion-action-one')));
    await tester.pumpAndSettle();
    expect(find.text('Learn destination'), findsOneWidget);
  });

  testWidgets('compact carousel remains usable at 200 percent text scale', (tester) async {
    await tester.pumpWidget(app([campaign('one', 'Free current affairs')], textScale: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Free current affairs'), findsOneWidget);
  });
}
