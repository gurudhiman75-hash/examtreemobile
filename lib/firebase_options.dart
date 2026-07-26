import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

enum FirebaseClientPlatform { web, android, ios, macos, windows }

class FirebaseBootstrapConfiguration {
  const FirebaseBootstrapConfiguration({
    required this.options,
    required this.missingDefines,
    required this.platform,
  });

  final FirebaseOptions? options;
  final List<String> missingDefines;
  final FirebaseClientPlatform platform;

  bool get isConfigured => options != null && missingDefines.isEmpty;
}

class FirebaseConfigurationException implements Exception {
  const FirebaseConfigurationException(this.missingDefines);

  final List<String> missingDefines;

  @override
  String toString() {
    return 'Firebase client configuration is incomplete: '
        '${missingDefines.join(', ')}';
  }
}

class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'sarbedutech',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1083299267005',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'sarbedutech.firebasestorage.app',
  );
  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'sarbedutech.firebaseapp.com',
  );
  static const String _webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:1083299267005:web:5f7f4374509edf703ad2d4',
  );
  static const String _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String _iosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
  );
  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );
  static const String _macosAppId = String.fromEnvironment(
    'FIREBASE_MACOS_APP_ID',
  );
  static const String _macosBundleId = String.fromEnvironment(
    'FIREBASE_MACOS_BUNDLE_ID',
  );

  static FirebaseBootstrapConfiguration get currentPlatformConfiguration {
    if (kIsWeb) return _resolve(FirebaseClientPlatform.web);

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _resolve(FirebaseClientPlatform.android),
      TargetPlatform.iOS => _resolve(FirebaseClientPlatform.ios),
      TargetPlatform.macOS => _resolve(FirebaseClientPlatform.macos),
      TargetPlatform.windows => _resolve(FirebaseClientPlatform.windows),
      TargetPlatform.linux => throw UnsupportedError(
          'Firebase is not configured for Linux.',
        ),
      _ => throw UnsupportedError(
          'Firebase is not supported for this platform.',
        ),
    };
  }

  static FirebaseOptions get currentPlatform {
    final configuration = currentPlatformConfiguration;
    final options = configuration.options;
    if (options == null) {
      throw FirebaseConfigurationException(configuration.missingDefines);
    }
    return options;
  }

  static FirebaseBootstrapConfiguration forValues({
    required FirebaseClientPlatform platform,
    String apiKey = _apiKey,
    String projectId = _projectId,
    String messagingSenderId = _messagingSenderId,
    String storageBucket = _storageBucket,
    String authDomain = _authDomain,
    String webAppId = _webAppId,
    String androidAppId = _androidAppId,
    String iosAppId = _iosAppId,
    String iosBundleId = _iosBundleId,
    String macosAppId = _macosAppId,
    String macosBundleId = _macosBundleId,
  }) {
    return _resolve(
      platform,
      apiKey: apiKey,
      projectId: projectId,
      messagingSenderId: messagingSenderId,
      storageBucket: storageBucket,
      authDomain: authDomain,
      webAppId: webAppId,
      androidAppId: androidAppId,
      iosAppId: iosAppId,
      iosBundleId: iosBundleId,
      macosAppId: macosAppId,
      macosBundleId: macosBundleId,
    );
  }

  static FirebaseBootstrapConfiguration _resolve(
    FirebaseClientPlatform platform, {
    String apiKey = _apiKey,
    String projectId = _projectId,
    String messagingSenderId = _messagingSenderId,
    String storageBucket = _storageBucket,
    String authDomain = _authDomain,
    String webAppId = _webAppId,
    String androidAppId = _androidAppId,
    String iosAppId = _iosAppId,
    String iosBundleId = _iosBundleId,
    String macosAppId = _macosAppId,
    String macosBundleId = _macosBundleId,
  }) {
    final missing = <String>[];

    void requireValue(String value, String defineName) {
      if (value.trim().isEmpty) missing.add(defineName);
    }

    requireValue(apiKey, 'FIREBASE_API_KEY');
    requireValue(projectId, 'FIREBASE_PROJECT_ID');
    requireValue(messagingSenderId, 'FIREBASE_MESSAGING_SENDER_ID');
    requireValue(storageBucket, 'FIREBASE_STORAGE_BUCKET');

    String appId;
    String? resolvedAuthDomain;
    String? resolvedBundleId;

    switch (platform) {
      case FirebaseClientPlatform.web:
      case FirebaseClientPlatform.windows:
        requireValue(webAppId, 'FIREBASE_WEB_APP_ID');
        requireValue(authDomain, 'FIREBASE_AUTH_DOMAIN');
        appId = webAppId;
        resolvedAuthDomain = authDomain;
        break;
      case FirebaseClientPlatform.android:
        requireValue(androidAppId, 'FIREBASE_ANDROID_APP_ID');
        appId = androidAppId;
        break;
      case FirebaseClientPlatform.ios:
        requireValue(iosAppId, 'FIREBASE_IOS_APP_ID');
        requireValue(iosBundleId, 'FIREBASE_IOS_BUNDLE_ID');
        appId = iosAppId;
        resolvedBundleId = iosBundleId;
        break;
      case FirebaseClientPlatform.macos:
        requireValue(macosAppId, 'FIREBASE_MACOS_APP_ID');
        requireValue(macosBundleId, 'FIREBASE_MACOS_BUNDLE_ID');
        appId = macosAppId;
        resolvedBundleId = macosBundleId;
        break;
    }

    if (missing.isNotEmpty) {
      return FirebaseBootstrapConfiguration(
        options: null,
        missingDefines: List.unmodifiable(missing),
        platform: platform,
      );
    }

    return FirebaseBootstrapConfiguration(
      options: FirebaseOptions(
        apiKey: apiKey.trim(),
        appId: appId.trim(),
        messagingSenderId: messagingSenderId.trim(),
        projectId: projectId.trim(),
        authDomain: resolvedAuthDomain?.trim(),
        storageBucket: storageBucket.trim(),
        iosBundleId: resolvedBundleId?.trim(),
      ),
      missingDefines: const [],
      platform: platform,
    );
  }
}
