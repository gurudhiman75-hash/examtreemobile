from pathlib import Path


def replace_once(path_str: str, old: str, new: str) -> None:
    path = Path(path_str)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path_str}: expected one anchor, found {count}')
    path.write_text(text.replace(old, new, 1))


replace_once(
    'lib/routes/app_router.dart',
    "import '../features/auth/presentation/providers/auth_providers.dart';\nimport '../features/exams/presentation/exam_details_screen.dart';",
    "import '../features/auth/presentation/providers/auth_providers.dart';\nimport '../features/companion/presentation/daily_companion_screen.dart';\nimport '../features/companion/presentation/quick_revision_screen.dart';\nimport '../features/exams/presentation/exam_details_screen.dart';",
)

replace_once(
    'lib/routes/app_router.dart',
    "      GoRoute(\n        path: '/test-attempt',",
    """      GoRoute(
        path: '/daily-companion',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyCompanionScreen(),
      ),
      GoRoute(
        path: '/quick-revision',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final raw = state.extra;
          final minutes = raw is int ? raw.clamp(1, 30).toInt() : 10;
          return QuickRevisionScreen(minutes: minutes);
        },
      ),
      GoRoute(
        path: '/test-attempt',""",
)

replace_once(
    'lib/features/home/presentation/home_screen_v3.dart',
    "                    const SizedBox(height: AppSpacing.md),\n                    _ContextActions(",
    """                    const SizedBox(height: AppSpacing.md),
                    _ContextActionCard(
                      key: const Key('home-daily-companion'),
                      icon: Icons.auto_awesome_rounded,
                      title: 'Daily Companion',
                      subtitle: 'Offline revision queue and local study reminders',
                      onTap: () => context.push('/daily-companion'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ContextActions(""",
)
