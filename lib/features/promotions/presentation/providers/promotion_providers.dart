import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/promotion_campaign.dart';

const promotionCampaignsRemoteKey = 'promotion_campaigns_json';

class PromotionCampaignSource {
  PromotionCampaignSource(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  Future<List<PromotionCampaign>> load() async {
    await _remoteConfig.setDefaults(const {
      promotionCampaignsRemoteKey: '[]',
    });
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 4),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Remote promotions are optional. Use the last activated/default value so
      // authentication and preparation never depend on the campaign service.
    }

    return parsePromotionCampaigns(
      _remoteConfig.getString(promotionCampaignsRemoteKey),
    );
  }
}

final promotionCampaignSourceProvider = Provider<PromotionCampaignSource?>((ref) {
  try {
    return PromotionCampaignSource(FirebaseRemoteConfig.instance);
  } catch (_) {
    // Widget tests and partially configured clients may not have a Firebase app.
    // Promotions are optional, so this must resolve to an empty campaign set
    // instead of entering Riverpod's retry cycle.
    return null;
  }
});

final promotionCampaignsProvider = FutureProvider<List<PromotionCampaign>>((ref) async {
  final source = ref.watch(promotionCampaignSourceProvider);
  if (source == null) return const <PromotionCampaign>[];
  return source.load();
});

final promotionClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final promotionsForPlacementProvider = FutureProvider.family<
    List<PromotionCampaign>, PromotionPlacement>((ref, placement) async {
  final campaigns = await ref.watch(promotionCampaignsProvider.future);
  final now = ref.watch(promotionClockProvider)();
  return selectPromotionCampaigns(
    campaigns: campaigns,
    placement: placement,
    now: now,
  );
});

class PromotionSessionRegistry {
  final Set<String> _presentedBeforeLogin = <String>{};
  final Set<String> _presentedPostLogin = <String>{};

  void markLoginCampaignsPresented(Iterable<PromotionCampaign> campaigns) {
    _presentedBeforeLogin.addAll(campaigns.map((campaign) => campaign.id));
  }

  bool wasPresentedBeforeLogin(String campaignId) =>
      _presentedBeforeLogin.contains(campaignId);

  bool shouldPresentPostLogin(PromotionCampaign campaign) =>
      !wasPresentedBeforeLogin(campaign.id) &&
      !_presentedPostLogin.contains(campaign.id);

  void markPostLoginCampaignPresented(String campaignId) {
    _presentedPostLogin.add(campaignId);
  }

  void clear() {
    _presentedBeforeLogin.clear();
    _presentedPostLogin.clear();
  }
}

final promotionSessionRegistryProvider = Provider<PromotionSessionRegistry>((ref) {
  return PromotionSessionRegistry();
});
