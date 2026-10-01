import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/providers/repository_providers.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../domain/promotion_campaign.dart';

const promotionCampaignsRemoteKey = 'promotion_campaigns_json';

class ApiMobilePromotionSource {
  const ApiMobilePromotionSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PromotionCampaign>> loadHome() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        'mobile/promotions',
        queryParameters: const <String, Object?>{'placement': 'home'},
      );
      final raw = response.data?['promotions'];
      if (raw is! List) return const <PromotionCampaign>[];

      final campaigns = <PromotionCampaign>[];
      for (final item in raw.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString().trim() ?? '';
        final title = map['title']?.toString().trim() ?? '';
        final subtitle = map['subtitle']?.toString().trim() ?? '';
        if (id.isEmpty || title.isEmpty) continue;

        final destinationType =
            map['destinationType']?.toString().trim() ?? 'none';
        final destinationValue =
            map['destinationValue']?.toString().trim() ?? '';
        String? deepLink;
        if (destinationType == 'exam' && destinationValue.isNotEmpty) {
          deepLink = '/exam-details?id=${Uri.encodeQueryComponent(destinationValue)}';
        } else if (destinationType == 'test_series') {
          deepLink = '/exams';
        } else if (destinationType == 'learn') {
          deepLink = destinationValue.startsWith('/') ? destinationValue : '/learn';
        }

        final order = int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0;
        campaigns.add(
          PromotionCampaign(
            id: id,
            title: title,
            subtitle: subtitle,
            placements: const <PromotionPlacement>{PromotionPlacement.home},
            ctaLabel: deepLink == null ? null : 'Explore',
            deepLink: deepLink,
            imageUrl: map['imageUrl']?.toString(),
            priority: 1000 - order,
          ),
        );
      }
      return List.unmodifiable(campaigns);
    } catch (_) {
      return const <PromotionCampaign>[];
    }
  }
}

final apiMobilePromotionSourceProvider = Provider<ApiMobilePromotionSource?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  return ApiMobilePromotionSource(ref.watch(apiClientProvider));
});


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
  final campaigns = placement == PromotionPlacement.home
      ? await (() async {
          final source = ref.watch(apiMobilePromotionSourceProvider);
          if (source == null) return const <PromotionCampaign>[];
          return source.loadHome();
        })()
      : await ref.watch(promotionCampaignsProvider.future);
  final now = ref.watch(promotionClockProvider)();
  final selectedExamIds = switch (audience) {
    AsyncData(value: final ids) => ids.toSet(),
    _ => const <String>{},
  };

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
