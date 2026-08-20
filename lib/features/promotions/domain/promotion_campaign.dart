import 'dart:convert';

enum PromotionPlacement { login, home, postLogin }

PromotionPlacement? promotionPlacementFromJson(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  return switch (normalized) {
    'login' => PromotionPlacement.login,
    'home' => PromotionPlacement.home,
    'postlogin' || 'post_login' || 'post-login' => PromotionPlacement.postLogin,
    _ => null,
  };
}

bool isSafePromotionDeepLink(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty || !raw.startsWith('/') || raw.startsWith('//')) return false;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return false;
  return uri.path.startsWith('/');
}

class PromotionCampaign {
  const PromotionCampaign({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.placements,
    this.ctaLabel,
    this.deepLink,
    this.imageUrl,
    this.priority = 0,
    this.startsAt,
    this.endsAt,
    this.languageCodes = const <String>[],
    this.examIds = const <String>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final Set<PromotionPlacement> placements;
  final String? ctaLabel;
  final String? deepLink;
  final String? imageUrl;
  final int priority;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final List<String> languageCodes;
  final List<String> examIds;

  bool get hasAction =>
      (ctaLabel?.trim().isNotEmpty ?? false) && isSafePromotionDeepLink(deepLink);

  bool isActiveAt(DateTime now) {
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && !now.isBefore(endsAt!)) return false;
    return true;
  }

  bool supportsLanguage(String? languageCode) {
    if (languageCodes.isEmpty || languageCode == null) return true;
    final normalized = languageCode.trim().toLowerCase();
    return languageCodes.any((code) => code.toLowerCase() == normalized);
  }

  bool targetsAnyExam(Set<String> selectedExamIds) {
    if (examIds.isEmpty || selectedExamIds.isEmpty) return true;
    return examIds.any(selectedExamIds.contains);
  }

  static PromotionCampaign? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.map((key, value) => MapEntry(key.toString(), value));
    final id = map['id']?.toString().trim() ?? '';
    final title = map['title']?.toString().trim() ?? '';
    final subtitle = map['subtitle']?.toString().trim() ?? '';
    if (id.isEmpty || title.isEmpty || subtitle.isEmpty) return null;

    final placementsRaw = map['placements'];
    if (placementsRaw is! List) return null;
    final placements = placementsRaw
        .map(promotionPlacementFromJson)
        .whereType<PromotionPlacement>()
        .toSet();
    if (placements.isEmpty) return null;

    String? optionalText(String key) {
      final value = map[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    DateTime? date(String key) {
      final value = optionalText(key);
      return value == null ? null : DateTime.tryParse(value)?.toUtc();
    }

    List<String> strings(String key) {
      final value = map[key];
      if (value is! List) return const <String>[];
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false);
    }

    final rawDeepLink = optionalText('deepLink');
    final safeDeepLink = isSafePromotionDeepLink(rawDeepLink) ? rawDeepLink : null;
    final priorityValue = map['priority'];
    final priority = priorityValue is num
        ? priorityValue.toInt()
        : int.tryParse(priorityValue?.toString() ?? '') ?? 0;

    return PromotionCampaign(
      id: id,
      title: title,
      subtitle: subtitle,
      placements: placements,
      ctaLabel: optionalText('ctaLabel'),
      deepLink: safeDeepLink,
      imageUrl: optionalText('imageUrl'),
      priority: priority,
      startsAt: date('startsAt'),
      endsAt: date('endsAt'),
      languageCodes: strings('languageCodes'),
      examIds: strings('examIds'),
    );
  }
}

List<PromotionCampaign> parsePromotionCampaigns(String jsonSource) {
  if (jsonSource.trim().isEmpty) return const <PromotionCampaign>[];
  try {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! List) return const <PromotionCampaign>[];
    final seen = <String>{};
    final campaigns = <PromotionCampaign>[];
    for (final item in decoded) {
      final campaign = PromotionCampaign.tryParse(item);
      if (campaign == null || !seen.add(campaign.id)) continue;
      campaigns.add(campaign);
    }
    return List.unmodifiable(campaigns);
  } catch (_) {
    return const <PromotionCampaign>[];
  }
}

List<PromotionCampaign> selectPromotionCampaigns({
  required Iterable<PromotionCampaign> campaigns,
  required PromotionPlacement placement,
  required DateTime now,
  String? languageCode,
  Set<String> selectedExamIds = const <String>{},
  int maxItems = 5,
}) {
  final active = campaigns
      .where((campaign) => campaign.placements.contains(placement))
      .where((campaign) => campaign.isActiveAt(now.toUtc()))
      .where((campaign) => campaign.supportsLanguage(languageCode))
      .where((campaign) => campaign.targetsAnyExam(selectedExamIds))
      .toList(growable: false)
    ..sort((a, b) {
      final priorityOrder = b.priority.compareTo(a.priority);
      if (priorityOrder != 0) return priorityOrder;
      return a.id.compareTo(b.id);
    });
  return List.unmodifiable(active.take(maxItems));
}
