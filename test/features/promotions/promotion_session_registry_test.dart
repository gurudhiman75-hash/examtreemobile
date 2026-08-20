import 'package:examtree/features/promotions/domain/promotion_campaign.dart';
import 'package:examtree/features/promotions/presentation/providers/promotion_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PromotionCampaign campaign(String id) => PromotionCampaign(
        id: id,
        title: 'Title',
        subtitle: 'Subtitle',
        placements: const {
          PromotionPlacement.login,
          PromotionPlacement.postLogin,
        },
      );

  test('post-login message skips campaigns already presented on Login', () {
    final registry = PromotionSessionRegistry();
    final shared = campaign('shared');

    expect(registry.shouldPresentPostLogin(shared), isTrue);
    registry.markLoginCampaignsPresented([shared]);
    expect(registry.shouldPresentPostLogin(shared), isFalse);
  });

  test('post-login campaign is shown at most once per app session', () {
    final registry = PromotionSessionRegistry();
    final message = campaign('post-login');

    expect(registry.shouldPresentPostLogin(message), isTrue);
    registry.markPostLoginCampaignPresented(message.id);
    expect(registry.shouldPresentPostLogin(message), isFalse);

    registry.clear();
    expect(registry.shouldPresentPostLogin(message), isTrue);
  });
}
