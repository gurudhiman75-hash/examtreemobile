import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/password_recovery_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/companion/presentation/daily_companion_screen.dart';
import '../features/companion/presentation/quick_revision_screen.dart';
import '../features/exam_day/presentation/exam_day_screen.dart';
import '../features/exams/presentation/exam_details_screen.dart';
import '../features/exams/presentation/exams_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/results/presentation/review_retry_screen.dart';
import '../features/test_attempt/presentation/canonical_test_attempt_screen.dart';
import '../shared/layouts/app_scaffold.dart';
import 'route_extra.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorExamsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellExams');
final GlobalKey<NavigatorState> _shellNavigatorResultsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellResults');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

String _continuationFor(Uri uri) {
  final path = uri.path.isEmpty ? '/home' : uri.path;
  return uri.hasQuery ? '$path?${uri.query}' : path;
}

String? _validatedContinuation(String? location) {
  if (location == null || !location.startsWith('/')) return null;
  if (location.startsWith('/login') || location.startsWith('/forgot-password')) {
    return null;
  }
  return location;
}

int _quickRevisionMinutes(Uri uri) {
  final requested = int.tryParse(uri.queryParameters['minutes'] ?? '');
  return const {5, 10, 20}.contains(requested) ? requested! : 5;
}

String? resolveAuthRedirect({
  required bool authReady,
  required bool isAuthenticated,
  required String matchedLocation,
  required Uri uri,
}) {
  final isLogin = matchedLocation == '/login';
  final isPublicAuthRoute =
      isLogin || matchedLocation == '/forgot-password';

  if (!authReady) return null;
  if (!isAuthenticated && !isPublicAuthRoute) {
    final continuation = Uri.encodeQueryComponent(_continuationFor(uri));
    return '/login?continue=$continuation';
  }
  if (isAuthenticated && isPublicAuthRoute) {
    if (isLogin) {
      final continuation = _validatedContinuation(
        uri.queryParameters['continue'],
      );
      if (continuation != null) return continuation;
    }
    return '/home';
  }
  return null;
}

class RouterAuthRefresh extends ChangeNotifier {
  RouterAuthRefresh(FirebaseAuth auth, AuthNavigationGate navigationGate)
      : _navigationGate = navigationGate,
        _user = auth.currentUser {
    _navigationGate.addListener(_handleNavigationGateChanged);
    _subscription = auth.authStateChanges().listen(
      (user) {
        _user = user;
        _ready = true;
        notifyListeners();
      },
      onError: (_) {
        // Firebase normally emits the restored user (or null) immediately. If
        // restoration itself errors, unlock routing with the last known user so
        // the UI can render a recoverable state instead of leaving the shell in
        // an indeterminate startup state.
        _ready = true;
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<User?> _subscription;
  final AuthNavigationGate _navigationGate;
  User? _user;
  bool _ready = false;

  bool get isReady => _ready;

  // Email/password Firebase users are not allowed into protected ExamTree
  // routes until Firebase has verified ownership of their email. Google
  // interactive sign-in additionally remains on the login route until the
  // canonical /users/me profile sync has completed successfully.
  bool get isAuthenticated =>
      _user != null &&
      _user!.emailVerified &&
      !_navigationGate.blocksAuthenticatedRedirect;

  void _handleNavigationGateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _navigationGate.removeListener(_handleNavigationGateChanged);
    _subscription.cancel();
    super.dispose();
  }
}

final routerAuthRefreshProvider = Provider<RouterAuthRefresh>((ref) {
  final refresh = RouterAuthRefresh(
    ref.watch(firebaseAuthProvider),
    ref.watch(authNavigationGateProvider),
  );
  ref.onDispose(refresh.dispose);
  return refresh;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  // Keep one GoRouter instance for the lifetime of this provider. Firebase auth
  // changes refresh redirect evaluation through ChangeNotifier rather than
  // reconstructing the stateful navigation shell with the same GlobalKeys.
  final authRefresh = ref.watch(routerAuthRefreshProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authRefresh,
    redirect: (context, state) => resolveAuthRedirect(
      authReady: authRefresh.isReady,
      isAuthenticated: authRefresh.isAuthenticated,
      matchedLocation: state.matchedLocation,
      uri: state.uri,
    ),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => PasswordRecoveryScreen(
          initialEmail: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorExamsKey,
            routes: [
              GoRoute(
                path: '/exams',
                builder: (context, state) => const ExamsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorResultsKey,
            routes: [
              GoRoute(
                path: '/results',
                builder: (context, state) => const ResultsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/daily',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyCompanionScreen(),
      ),
      GoRoute(
        path: '/exam-day',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExamDayScreen(),
      ),
      GoRoute(
        path: '/quick-revision',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuickRevisionScreen(
          minutes: _quickRevisionMinutes(state.uri),
        ),
      ),
      GoRoute(
        path: '/test-attempt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = readRequiredRouteId(state.extra);
          if (examId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Test unavailable',
              message:
                  'No test identifier was supplied. Open the test again from the exam catalogue.',
            );
          }
          return CanonicalTestAttemptScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/exam-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = readRequiredRouteId(state.extra);
          if (examId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Exam unavailable',
              message:
                  'No exam identifier was supplied. Choose an exam from the catalogue.',
            );
          }
          return ExamDetailsScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final resultId = readRequiredRouteId(state.extra);
          if (resultId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Result unavailable',
              message:
                  'No attempt identifier was supplied. Open the result again from your history.',
            );
          }
          return ReviewRetryScreen(resultId: resultId);
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _MissingRouteIdentifierScreen extends StatelessWidget {
  const _MissingRouteIdentifierScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link_off_outlined,
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
