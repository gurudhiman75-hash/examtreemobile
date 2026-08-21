import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
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

/// Returns My Exams only for a verified authenticated learner. Firebase-less
/// tests, signed-out clients, loading preferences and preference failures all
/// fail closed for exam-targeted campaigns while general campaigns remain safe.
final promotionAudienceExamIdsProvider = Provider<AsyncValue<List<String>>?>((ref) {
  try {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null || !user.emailVerified) return null;
    return ref.watch(selectedExamIdsProvider);
  } catch (_) {
    return null;
  }
});

final promotionsForPlacementProvider = FutureProvider.family<
    List<PromotionCampaign>, PromotionPlacement>((ref, placement) async {
  final audience = placement == PromotionPlacement.login
      ? null
      : ref.watch(promotionAudienceExamIdsProvider);
  final campaigns = await ref.watch(promotionCampaignsProvider.future);
  final now = ref.watch(promotionClockProvider)();
  final selectedExamIds = audience?.value?.toSet() ?? const <String>{};

  return selectPromotionCampaigns(
    campaigns: campaigns,
    placement: placement,
    now: now,
    selectedExamIds: selectedExamIds,
    // Login remains unchanged because the learner is not authenticated there.
    // Home/post-login require a real My Exams match before targeted copy appears.
    requireExplicitExamMatch: placement != PromotionPlacement.login,
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
