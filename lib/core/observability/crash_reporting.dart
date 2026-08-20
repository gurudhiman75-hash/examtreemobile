import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class SanitizedUnhandledError implements Exception {
  const SanitizedUnhandledError({
    required this.source,
    required this.originalType,
  });

  final String source;
  final String originalType;

  @override
  String toString() => 'Unhandled $source error ($originalType)';
}

Future<void> configureCrashReporting() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  if (kDebugMode) return;

  await crashlytics.setCustomKey('app_surface', 'mobile');
  await crashlytics.setCustomKey('error_payload_policy', 'sanitized');

  FlutterError.onError = (details) {
    final stack = details.stack ?? StackTrace.current;
    unawaited(
      crashlytics.recordError(
        SanitizedUnhandledError(
          source: 'flutter-framework',
          originalType: details.exception.runtimeType.toString(),
        ),
        stack,
        fatal: true,
        reason: 'flutter-framework',
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      crashlytics.recordError(
        SanitizedUnhandledError(
          source: 'platform-async',
          originalType: error.runtimeType.toString(),
        ),
        stack,
        fatal: true,
        reason: 'platform-async',
      ),
    );
    return true;
  };
}
