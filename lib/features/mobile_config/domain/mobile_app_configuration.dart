class MobileAppConfiguration {
  const MobileAppConfiguration({
    required this.minimumSupportedVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.playStoreUrl,
    required this.supportUrl,
    required this.defaultLanguage,
    required this.featureFlags,
  });

  final String minimumSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String playStoreUrl;
  final String supportUrl;
  final String defaultLanguage;
  final Map<String, bool> featureFlags;

  static const fallback = MobileAppConfiguration(
    minimumSupportedVersion: '',
    latestVersion: '',
    forceUpdate: false,
    maintenanceMode: false,
    maintenanceMessage: '',
    playStoreUrl: '',
    supportUrl: '',
    defaultLanguage: 'en',
    featureFlags: <String, bool>{},
  );

  factory MobileAppConfiguration.fromJson(Map<String, dynamic> json) {
    final rawFlags = json['featureFlags'];
    final flags = <String, bool>{};
    if (rawFlags is Map) {
      for (final entry in rawFlags.entries) {
        flags[entry.key.toString()] = entry.value == true;
      }
    }
    return MobileAppConfiguration(
      minimumSupportedVersion:
          json['minimumSupportedVersion']?.toString() ?? '',
      latestVersion: json['latestVersion']?.toString() ?? '',
      forceUpdate: json['forceUpdate'] == true,
      maintenanceMode: json['maintenanceMode'] == true,
      maintenanceMessage: json['maintenanceMessage']?.toString() ?? '',
      playStoreUrl: json['playStoreUrl']?.toString() ?? '',
      supportUrl: json['supportUrl']?.toString() ?? '',
      defaultLanguage: json['defaultLanguage']?.toString() ?? 'en',
      featureFlags: flags,
    );
  }

  bool isFeatureEnabled(String key, {bool fallback = false}) {
    return featureFlags[key] ?? fallback;
  }
}

int compareSemanticVersions(String a, String b) {
  List<int> parts(String value) {
    final core = value.trim().split('+').first.split('-').first;
    return core
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }

  final left = parts(a);
  final right = parts(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var index = 0; index < length; index += 1) {
    final l = index < left.length ? left[index] : 0;
    final r = index < right.length ? right[index] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}
