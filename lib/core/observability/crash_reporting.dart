import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

const examtreeCrashDefaultAppVersion = '1.0.1';
const examtreeCrashAppVersion = String.fromEnvironment(
  'EXAMTREE_APP_VERSION',
  defaultValue: examtreeCrashDefaultAppVersion,
);

String _lastCrashRoutePath = '';

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

String sanitizeCrashRoute(Uri uri) {
  final path = uri.path.trim();
  if (!path.startsWith('/') || path.length > 96) return 'unknown';
  return path.isEmpty ? '/' : path;
}

Future<void> recordCrashRoute(Uri uri) async {
  if (kDebugMode) return;

  final routePath = sanitizeCrashRoute(uri);
  if (_lastCrashRoutePath == routePath) return;
  _lastCrashRoutePath = routePath;

  try {
    await FirebaseCrashlytics.instance.setCustomKey('route_path', routePath);
  } catch (_) {
    // Observability must never interfere with navigation.
  }
}

Future<void> configureCrashReporting() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  if (kDebugMode) return;

  await crashlytics.setCustomKey('app_surface', 'mobile');
  await crashlytics.setCustomKey('app_version', examtreeCrashAppVersion);
  await crashlytics.setCustomKey('route_path', 'startup');
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
