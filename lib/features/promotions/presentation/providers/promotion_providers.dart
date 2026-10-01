import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../../preferences/domain/question_language.dart';
import '../../../preferences/presentation/providers/question_language_providers.dart';
import '../../data/local_promotion_exposure_store.dart';
import '../../domain/promotion_campaign.dart';

const promotionCampaignsRemoteKey = 'promotion_campaigns_json';

String _apiPlacement(PromotionPlacement placement) => switch (placement) {
      PromotionPlacement.home => 'home',
      PromotionPlacement.learn => 'learn',
      PromotionPlacement.tests => 'tests',
      PromotionPlacement.results => 'results',
      PromotionPlacement.postLogin => 'login_popup',
      _ => 'home',
    };

String _languageCode(QuestionLanguage language) => switch (language) {
      QuestionLanguage.english => 'en',
      QuestionLanguage.hindi => 'hi',
      QuestionLanguage.punjabi => 'pa',
    };

class ApiMobilePromotionSource {
  const ApiMobilePromotionSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PromotionCampaign>> load(PromotionPlacement placement) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        'mobile/promotions',
        queryParameters: <String, Object?>{
          'placement': _apiPlacement(placement),
        },
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
        String? externalUrl;
        if (destinationType == 'exam' && destinationValue.isNotEmpty) {
          deepLink =
              '/exam-details?id=${Uri.encodeQueryComponent(destinationValue)}';
        } else if (destinationType == 'test_series') {
          deepLink = '/store?section=tests';
        } else if (destinationType == 'learn') {
          deepLink =
              destinationValue.startsWith('/') ? destinationValue : '/learn';
        } else if (destinationType == 'page' && destinationValue.isNotEmpty) {
          deepLink = '/page/${Uri.encodeComponent(destinationValue)}';
        } else if (destinationType == 'url' &&
            isSafePromotionExternalUrl(destinationValue)) {
          externalUrl = destinationValue;
        }

        final audienceRaw = map['audience'];
        final audience = audienceRaw is Map
            ? Map<String, dynamic>.from(audienceRaw)
            : const <String, dynamic>{};
        List<String> list(String key) {
          final value = audience[key];
          if (value is! List) return const <String>[];
          return value
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toSet()
              .toList(growable: false);
        }

        final order = int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0;
        final cap =
            int.tryParse(map['frequencyCapPerDay']?.toString() ?? '');

        campaigns.add(
          PromotionCampaign(
            id: id,
            title: title,
            subtitle: subtitle,
            placements: <PromotionPlacement>{placement},
            ctaLabel: deepLink == null && externalUrl == null ? null : 'Explore',
            deepLink: deepLink,
            externalUrl: externalUrl,
            imageUrl: map['imageUrl']?.toString(),
            priority: 1000 - order,
            languageCodes: list('languageCodes'),
            examIds: list('examIds'),
            isDismissible: map['isDismissible'] == true,
            frequencyCapPerDay: cap != null && cap > 0 ? cap : null,
          ),
        );
      }
      return List.unmodifiable(campaigns);
    } catch (_) {
      return const <PromotionCampaign>[];
    }
  }
}

final apiMobilePromotionSourceProvider =
    Provider<ApiMobilePromotionSource?>((ref) {
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

final promotionCampaignSourceProvider =
    Provider<PromotionCampaignSource?>((ref) {
  try {
    return PromotionCampaignSource(FirebaseRemoteConfig.instance);
  } catch (_) {
    return null;
  }
});

final promotionCampaignsProvider =
    FutureProvider<List<PromotionCampaign>>((ref) async {
  final source = ref.watch(promotionCampaignSourceProvider);
  if (source == null) return const <PromotionCampaign>[];
  return source.load();
});

final promotionClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

final promotionExposureStoreProvider =
    Provider<LocalPromotionExposureStore>((ref) {
  return LocalPromotionExposureStore();
});

/// Returns My Exams only for an authenticated learner. Firebase-less tests,
/// signed-out clients, loading preferences and preference failures fail closed
/// for exam-targeted campaigns while general campaigns remain safe.
final promotionAudienceExamIdsProvider =
    Provider<AsyncValue<List<String>>?>((ref) {
  try {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final authenticated = user != null &&
        (user.emailVerified ||
            (user.phoneNumber?.trim().isNotEmpty ?? false));
    if (!authenticated) return null;
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

  final isApiPlacement = {
    PromotionPlacement.home,
    PromotionPlacement.learn,
    PromotionPlacement.tests,
    PromotionPlacement.results,
    PromotionPlacement.postLogin,
  }.contains(placement);

  final campaigns = isApiPlacement
      ? await (() async {
          final source = ref.watch(apiMobilePromotionSourceProvider);
          if (source == null) return const <PromotionCampaign>[];
          return source.load(placement);
        })()
      : await ref.watch(promotionCampaignsProvider.future);

  final now = ref.watch(promotionClockProvider)();
  final selectedExamIds = switch (audience) {
    AsyncData(value: final ids) => ids.toSet(),
    _ => const <String>{},
  };

  String? languageCode;
  if (placement != PromotionPlacement.login) {
    try {
      languageCode =
          _languageCode(await ref.watch(questionLanguageProvider.future));
    } catch (_) {
      languageCode = 'en';
    }
  }

  final selected = selectPromotionCampaigns(
    campaigns: campaigns,
    placement: placement,
    now: now,
    languageCode: languageCode,
    selectedExamIds: selectedExamIds,
    requireExplicitExamMatch: placement != PromotionPlacement.login,
  );

  final exposureStore = ref.watch(promotionExposureStoreProvider);
  final visible = <PromotionCampaign>[];
  for (final campaign in selected) {
    if (await exposureStore.isEligible(campaign, now: now)) {
      visible.add(campaign);
    }
  }
  return List.unmodifiable(visible);
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

final promotionSessionRegistryProvider =
    Provider<PromotionSessionRegistry>((ref) {
  return PromotionSessionRegistry();
});
