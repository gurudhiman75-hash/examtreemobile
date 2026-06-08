import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/exams/presentation/exams_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/results/presentation/review_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/test_attempt/presentation/test_attempt_screen.dart';
import '../features/exams/presentation/exam_details_screen.dart';
import '../shared/layouts/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorExamsKey = GlobalKey<NavigatorState>(debugLabel: 'shellExams');
final GlobalKey<NavigatorState> _shellNavigatorResultsKey = GlobalKey<NavigatorState>(debugLabel: 'shellResults');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
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
          final examId = state.extra as String? ?? 'exam_1'; // fallback
          return TestAttemptScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/exam-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = state.extra as String? ?? 'exam_1'; // fallback
          return ExamDetailsScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final resultId = state.extra as String? ?? 'res_1'; // fallback
          return ReviewScreen(resultId: resultId);
        },
      ),
    ],
  );
});
