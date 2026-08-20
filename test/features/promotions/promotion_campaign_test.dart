import 'package:examtree/features/promotions/domain/promotion_campaign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses valid remote campaigns and rejects malformed entries', () {
    final campaigns = parsePromotionCampaigns('''
      [
        {
          "id": "login-1",
          "title": "Free current affairs",
          "subtitle": "Daily and monthly revision",
          "placements": ["login", "home"],
          "ctaLabel": "Explore",
          "deepLink": "/learn",
          "priority": 5
        },
        {"id": "broken", "title": "Missing fields"}
      ]
    ''');

    expect(campaigns, hasLength(1));
    expect(campaigns.single.id, 'login-1');
    expect(campaigns.single.placements, contains(PromotionPlacement.login));
    expect(campaigns.single.hasAction, isTrue);
  });

  test('unsafe external or protocol-relative links never become CTA routes', () {
    for (final link in ['https://example.com', '//example.com', 'javascript:x']) {
      final campaign = PromotionCampaign.tryParse({
        'id': 'one',
        'title': 'Title',
        'subtitle': 'Subtitle',
        'placements': ['login'],
        'ctaLabel': 'Open',
        'deepLink': link,
      });
      expect(campaign, isNotNull);
      expect(campaign!.deepLink, isNull);
      expect(campaign.hasAction, isFalse);
    }
    expect(isSafePromotionDeepLink('/learn?tab=daily'), isTrue);
  });

  test('selection enforces placement schedule priority and max count', () {
    final now = DateTime.utc(2026, 8, 20, 8);
    PromotionCampaign campaign(
      String id,
      int priority, {
      DateTime? startsAt,
      DateTime? endsAt,
      PromotionPlacement placement = PromotionPlacement.home,
    }) =>
        PromotionCampaign(
          id: id,
          title: id,
          subtitle: 'Copy',
          placements: {placement},
          priority: priority,
          startsAt: startsAt,
          endsAt: endsAt,
        );

    final selected = selectPromotionCampaigns(
      campaigns: [
        campaign('low', 1),
        campaign('high', 10),
        campaign('future', 99, startsAt: now.add(const Duration(hours: 1))),
        campaign('expired', 99, endsAt: now),
        campaign('login-only', 100, placement: PromotionPlacement.login),
      ],
      placement: PromotionPlacement.home,
      now: now,
      maxItems: 2,
    );

    expect(selected.map((item) => item.id), ['high', 'low']);
  });

  test('invalid JSON safely resolves to no campaigns', () {
    expect(parsePromotionCampaigns('{not-json'), isEmpty);
    expect(parsePromotionCampaigns('{}'), isEmpty);
    expect(parsePromotionCampaigns(''), isEmpty);
  });
}
