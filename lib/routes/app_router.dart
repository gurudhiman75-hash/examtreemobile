import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/exams/presentation/exam_details_screen.dart';
import '../features/exams/presentation/exams_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/results/presentation/review_screen.dart';
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

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) return null;
      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
        path: '/test-attempt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = readRequiredRouteId(state.extra);
          if (examId == null) {
            return const _MissingRouteIdentifierScreen(
              title: 'Test unavailable',
              message: 'No test identifier was supplied. Open the test again from the exam catalogue.',
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
              message: 'No exam identifier was supplied. Choose an exam from the catalogue.',
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
              message: 'No attempt identifier was supplied. Open the result again from your history.',
            );
          }
          return ReviewScreen(resultId: resultId);
        },
      ),
    ],
  );
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
