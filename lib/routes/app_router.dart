import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/observability/crash_reporting.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/password_recovery_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/companion/presentation/daily_companion_screen.dart';
import '../features/companion/presentation/quick_revision_screen.dart';
import '../features/current_affairs/presentation/current_affairs_screen.dart';
import '../features/exam_day/presentation/exam_day_screen.dart';
import '../features/exam_preferences/presentation/my_exams_screen.dart';
import '../features/exams/presentation/exam_details_screen.dart';
import '../features/exams/presentation/exams_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/mobile_test_series_detail_screen.dart';
import '../features/learn/presentation/learn_course_screen.dart';
import '../features/learn/presentation/learn_module_screen.dart';
import '../features/learn/presentation/learn_practice_result_screen.dart';
import '../features/learn/presentation/learn_practice_screen.dart';
import '../features/learn/presentation/learn_submodule_screen.dart';
import '../features/learn/presentation/learn_lesson_screen.dart';
import '../features/learn/presentation/learn_screen.dart';
import '../features/learn/presentation/learning_resource_detail_screen.dart';
import '../features/notifications/presentation/mobile_notifications_screen.dart';
import '../features/profile/presentation/account_settings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/results/presentation/review_retry_screen.dart';
import '../features/store/presentation/store_screen.dart';
import '../features/test_attempt/presentation/canonical_test_attempt_screen.dart';
import '../shared/layouts/app_scaffold.dart';
import 'route_extra.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorLearnKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellLearn');
final GlobalKey<NavigatorState> _shellNavigatorExamsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellExams');
final GlobalKey<NavigatorState> _shellNavigatorCurrentAffairsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellCurrentAffairs');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

bool _routeNeedsIdentifier(String path) => const {
      '/exam-details',
      '/test-attempt',
      '/review',
      '/learn-resource',
      '/learn-lesson',
    }.contains(path);

String _continuationFor(Uri uri, {Object? routeExtra}) {
  var durableUri = uri;
  if (_routeNeedsIdentifier(uri.path) &&
      (uri.queryParameters['id']?.trim().isEmpty ?? true)) {
    final routeId = readRequiredRouteId(routeExtra);
    if (routeId != null) {
      durableUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'id': routeId,
        },
      );
    }
  }

  final path = durableUri.path.isEmpty ? '/home' : durableUri.path;
  return durableUri.hasQuery ? '$path?${durableUri.query}' : path;
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
  Object? routeExtra,
}) {
  final isLogin = matchedLocation == '/login';
  final isPublicAuthRoute =
      isLogin || matchedLocation == '/forgot-password';

  if (!authReady) return null;
  if (!isAuthenticated && !isPublicAuthRoute) {
    final continuation = Uri.encodeQueryComponent(
      _continuationFor(uri, routeExtra: routeExtra),
    );
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

  bool get isAuthenticated {
    final user = _user;
    if (user == null || _navigationGate.blocksAuthenticatedRedirect) {
      return false;
    }
    final hasVerifiedEmail = user.emailVerified;
    final hasVerifiedPhone = user.phoneNumber?.trim().isNotEmpty ?? false;
    return hasVerifiedEmail || hasVerifiedPhone;
  }

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
  final authRefresh = ref.watch(routerAuthRefreshProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      unawaited(recordCrashRoute(state.uri));
      return resolveAuthRedirect(
        authReady: authRefresh.isReady,
        isAuthenticated: authRefresh.isAuthenticated,
        matchedLocation: state.matchedLocation,
        uri: state.uri,
        routeExtra: state.extra,
      );
    },
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
            navigatorKey: _shellNavigatorLearnKey,
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
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
            navigatorKey: _shellNavigatorCurrentAffairsKey,
            routes: [
              GoRoute(
                path: '/current-affairs',
                builder: (context, state) => const CurrentAffairsScreen(),
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
        path: '/results',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => Scaffold(
          backgroundColor: const Color(0xFFFBFCFE),
          appBar: AppBar(
            title: const Text('Results'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF10264A),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFE8EDF3)),
            ),
          ),
          body: const ResultsScreen(),
        ),
      ),
      GoRoute(
        path: '/account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/my-exams',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyExamsScreen(),
      ),
      GoRoute(
        path: '/store',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StoreScreen(
          initialSection: storeSectionFromQuery(
            state.uri.queryParameters['section'],
          ),
        ),
      ),
      GoRoute(
        path: '/test-series',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final seriesId = state.uri.queryParameters['id']?.trim() ?? '';
          if (seriesId.isEmpty) {
            return const _MissingRouteIdentifierScreen(
              title: 'Test series unavailable',
              message: 'No test-series identifier was supplied. Open the series again from Home.',
            );
          }
          return MobileTestSeriesDetailScreen(seriesId: seriesId);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MobileNotificationsScreen(),
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
        path: '/learn-module',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LearnModuleScreen(
          moduleId: state.uri.queryParameters['module'] ?? '',
        ),
      ),
      GoRoute(
        path: '/learn-submodule',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LearnSubmoduleScreen(
          submoduleId: state.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/learn-practice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LearnPracticeScreen(
          topicId: state.uri.queryParameters['topic'] ?? '',
          fresh: state.uri.queryParameters['fresh'] == '1',
        ),
      ),
      GoRoute(
        path: '/learn-practice-result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LearnPracticeResultScreen(
          topicId: state.uri.queryParameters['topic'] ?? '',
          correct: int.tryParse(state.uri.queryParameters['correct'] ?? '') ?? 0,
          total: int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/learn-course',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LearnCourseScreen(
          subjectCode: state.uri.queryParameters['subject'] ?? '',
        ),
      ),
      GoRoute(
        path: '/learn-lesson',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final lessonId = readRequiredRouteId(state.extra, uri: state.uri);
          if (lessonId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Lesson unavailable',
              message: 'No lesson identifier was supplied. Open the lesson again from Learn.',
            );
          }
          return LearnLessonScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/learn-resource',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final resourceId = readRequiredRouteId(state.extra, uri: state.uri);
          if (resourceId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Resource unavailable',
              message:
                  'No learning resource identifier was supplied. Open the resource again from Learn.',
            );
          }
          return LearningResourceDetailScreen(resourceId: resourceId);
        },
      ),
      GoRoute(
        path: '/test-attempt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = readRequiredRouteId(state.extra, uri: state.uri);
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
          final examId = readRequiredRouteId(state.extra, uri: state.uri);
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
          final resultId = readRequiredRouteId(state.extra, uri: state.uri);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE3E9F1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10264A).withValues(alpha: .04),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.link_off_outlined,
                      size: 29,
                      color: Color(0xFF0B5D96),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF10264A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF073A6A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle:
                          const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
