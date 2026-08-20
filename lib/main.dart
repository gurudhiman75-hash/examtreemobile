import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/repository_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/companion/presentation/providers/daily_companion_providers.dart';
import 'features/exam_day/presentation/providers/exam_day_providers.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseBootstrapConfiguration configuration;
  try {
    configuration = DefaultFirebaseOptions.currentPlatformConfiguration;
  } catch (error) {
    runApp(
      FirebaseStartupErrorApp(
        title: 'Platform not configured',
        message: error.toString(),
      ),
    );
    return;
  }

  if (!configuration.isConfigured) {
    runApp(
      FirebaseConfigurationRequiredApp(
        missingDefines: configuration.missingDefines,
      ),
    );
    return;
  }

  try {
    if (configuration.platform == FirebaseClientPlatform.android) {
      // Android uses the refreshed google-services.json processed by the
      // Google Services Gradle plugin. This keeps Firebase Auth, Google Sign-In,
      // the Android OAuth client, API key, package name and SHA registration on
      // the same native configuration source.
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(options: configuration.options);
    }
  } catch (error) {
    runApp(
      FirebaseStartupErrorApp(
        title: 'Firebase failed to start',
        message: error.toString(),
      ),
    );
    return;
  }

  runApp(const ProviderScope(child: ExamTreeApp()));
}

class ExamTreeApp extends ConsumerWidget {
  const ExamTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Free Render instances may be asleep when the app opens. Start the wakeup
    // request in the background immediately; authentication will await the same
    // shared readiness probe if the user reaches Login before it completes.
    ref.watch(apiServerWarmupProvider);

    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user == null) {
          unawaited(ref.read(companionWidgetServiceProvider).clear());
          unawaited(ref.read(examDayControllerProvider).cancelReminders());
        } else {
          unawaited(
            ref.read(examDayControllerProvider).restoreReminders(user.uid),
          );
        }
      });
    });

    return MaterialApp.router(
      title: 'ExamTree',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseConfigurationRequiredApp extends StatelessWidget {
  const FirebaseConfigurationRequiredApp({
    super.key,
    required this.missingDefines,
  });

  final List<String> missingDefines;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamTree setup',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('ExamTree setup required')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.build_circle_outlined, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    'This ExamTree build is not configured correctly.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Install the latest official build, then try again.',
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        missingDefines
                            .map((name) => '--dart-define=$name=<value>')
                            .join('\n'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FirebaseStartupErrorApp extends StatelessWidget {
  const FirebaseStartupErrorApp({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamTree startup error',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ExamTree could not start its authentication service.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Close and reopen the app. If the problem continues, try again later.',
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
