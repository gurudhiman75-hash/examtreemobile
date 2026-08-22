import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/daily_companion.dart';
import 'providers/daily_companion_providers.dart';
import 'quick_revision_screen.dart';

class DailyCompanionScreen extends ConsumerWidget {
  const DailyCompanionScreen({super.key});

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    StudyCompanionSettings settings,
  ) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    try {
      final ready = await ref
          .read(dailyCompanionControllerProvider)
          .saveSettings(userId: user.uid, settings: settings);
      ref.invalidate(dailyCompanionSnapshotProvider);
      if (context.mounted && settings.reminderEnabled && !ready) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study plan saved, but notifications are disabled.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save the study plan.')),
        );
      }
    }
  }

  void _openQuickRevision(BuildContext context, int minutes) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuickRevisionScreen(minutes: minutes),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(dailyCompanionSnapshotProvider);
    final now = ref.watch(dailyCompanionClockProvider)();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Companion'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dailyCompanionSnapshotProvider),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: snapshotAsync.when(
        loading: () => const _DailyLoadingState(),
        error: (error, stackTrace) => _DailyErrorState(
          onRetry: () => ref.invalidate(dailyCompanionSnapshotProvider),
        ),
        data: (snapshot) {
          final due = snapshot.dueItems(now);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dailyCompanionSnapshotProvider);
              try {
                await ref.read(dailyCompanionSnapshotProvider.future);
              } catch (_) {}
            },
            child: ListView(
              key: const Key('daily-companion-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                _TodayHero(snapshot: snapshot, dueCount: due.length),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(
                  title: 'Quick revision',
                  subtitle: due.isEmpty
                      ? 'Nothing is due right now.'
                      : 'Choose a focused session from questions due now.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuickRevisionActions(
                  enabled: due.isNotEmpty,
                  onOpen: (minutes) => _openQuickRevision(context, minutes),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExamDayLink(onTap: () => context.push('/exam-day')),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Revision queue',
                  subtitle: due.isEmpty
                      ? '${snapshot.items.length} saved questions · nothing due now'
                      : '${due.length} due now · ${snapshot.items.length} saved',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (snapshot.items.isEmpty)
                  const _EmptyRevisionQueue()
                else
                  ...snapshot.items.take(8).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _RevisionQueueItem(item: item, now: now),
                        ),
                      ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionHeader(
                  title: 'Study plan',
                  subtitle: 'Keep your daily target and local reminder realistic.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _StudyPlanCard(
                  settings: snapshot.settings,
                  onChanged: (settings) => _save(context, ref, settings),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyLoadingState extends StatelessWidget {
  const _DailyLoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 118,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 92,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ],
    );
  }
}

class _DailyErrorState extends StatelessWidget {
  const _DailyErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 30,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Daily Companion is unavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your saved revision queue is still on this device. Try loading it again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Daily Companion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.snapshot, required this.dueCount});

  final DailyCompanionSnapshot snapshot;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final goal = snapshot.settings.dailyQuestionGoal;
    final progress = goal <= 0
        ? 0.0
        : (snapshot.completedToday / goal).clamp(0.0, 1.0).toDouble();

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Today’s revision',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          dueCount == 0
              ? 'You are caught up for now.'
              : '$dueCount ${dueCount == 1 ? 'question is' : 'questions are'} due now.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            height: 1.35,
          ),
        ),
      ],
    );

    final dueBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$dueCount due',
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Container(
      key: const Key('daily-summary'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (largeText) ...[
            dueBadge,
            const SizedBox(height: AppSpacing.md),
            copy,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: copy),
                const SizedBox(width: AppSpacing.md),
                dueBadge,
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label:
                '${snapshot.completedToday} of $goal reviews completed today',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.86),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${snapshot.completedToday} of $goal reviews completed today',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _QuickRevisionActions extends StatelessWidget {
  const _QuickRevisionActions({required this.enabled, required this.onOpen});

  final bool enabled;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final actions = [
      for (final minutes in const [5, 10, 20])
        FilledButton.tonalIcon(
          key: Key('quick-revision-$minutes'),
          onPressed: enabled ? () => onOpen(minutes) : null,
          icon: Icon(
            minutes == 5
                ? Icons.bolt_rounded
                : minutes == 10
                    ? Icons.timer_outlined
                    : Icons.psychology_alt_outlined,
            size: 19,
          ),
          label: Text('$minutes min'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 54),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
    ];

    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            actions[index],
            if (index != actions.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Expanded(child: actions[index]),
          if (index != actions.length - 1)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ExamDayLink extends StatelessWidget {
  const _ExamDayLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.skyContainer,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: AppColors.onSkyContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam-Day Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSkyContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Countdown, logistics checklist and local reminders',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSkyContainer,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSkyContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRevisionQueue extends StatelessWidget {
  const _EmptyRevisionQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('revision-queue-empty'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.mintContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.onMintContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Complete tests to build a private revision queue from wrong, skipped, flagged and unusually slow questions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onMintContainer,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionQueueItem extends StatelessWidget {
  const _RevisionQueueItem({required this.item, required this.now});

  final RevisionItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = item.isDue(now);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final status = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: due ? AppColors.amberContainer : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        due ? 'Due' : _date(item.dueAt),
        style: theme.textTheme.labelSmall?.copyWith(
          color: due ? AppColors.onAmberContainer : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    final title = Text(
      item.questionText,
      maxLines: largeText ? 4 : 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.35,
      ),
    );

    return Container(
      key: Key('revision-item-${item.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (largeText) ...[
            status,
            const SizedBox(height: AppSpacing.sm),
            title,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: AppSpacing.sm),
                status,
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [item.testName, item.section]
                .where((value) => value.trim().isNotEmpty)
                .join(' · '),
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (item.reasons.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final reason in item.reasons)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      reason.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  const _StudyPlanCard({required this.settings, required this.onChanged});

  final StudyCompanionSettings settings;
  final ValueChanged<StudyCompanionSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Material(
      key: const Key('study-plan'),
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My study plan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Set a realistic daily review target and an optional local reminder.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _GoalControl(
              settings: settings,
              stacked: textScale >= 1.5,
              onChanged: onChanged,
            ),
            const Divider(height: AppSpacing.xl),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Local study reminder',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                TimeOfDay(
                  hour: settings.reminderHour,
                  minute: settings.reminderMinute,
                ).format(context),
              ),
              value: settings.reminderEnabled,
              onChanged: (value) =>
                  onChanged(settings.copyWith(reminderEnabled: value)),
            ),
            if (settings.reminderEnabled) ...[
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.reminderHour,
                      minute: settings.reminderMinute,
                    ),
                  );
                  if (picked != null) {
                    onChanged(
                      settings.copyWith(
                        reminderHour: picked.hour,
                        reminderMinute: picked.minute,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Change reminder time'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalControl extends StatelessWidget {
  const _GoalControl({
    required this.settings,
    required this.stacked,
    required this.onChanged,
  });

  final StudyCompanionSettings settings;
  final bool stacked;
  final ValueChanged<StudyCompanionSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          tooltip: 'Decrease daily question goal',
          onPressed: settings.dailyQuestionGoal > 1
              ? () => onChanged(
                    settings.copyWith(
                      dailyQuestionGoal: settings.dailyQuestionGoal - 1,
                    ),
                  )
              : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 52,
          child: Text(
            '${settings.dailyQuestionGoal}',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.outlined(
          tooltip: 'Increase daily question goal',
          onPressed: settings.dailyQuestionGoal < 100
              ? () => onChanged(
                    settings.copyWith(
                      dailyQuestionGoal: settings.dailyQuestionGoal + 1,
                    ),
                  )
              : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );

    final label = Text(
      'Daily question goal',
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: AppSpacing.sm),
          controls,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: label),
        const SizedBox(width: AppSpacing.sm),
        controls,
      ],
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.055),
        blurRadius: 22,
        offset: const Offset(0, 8),
      ),
    ];

String _date(DateTime value) {
  final local = value.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${local.day} ${months[local.month - 1]}';
}
