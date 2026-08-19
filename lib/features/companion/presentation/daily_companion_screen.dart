import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
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
                _TodayCard(snapshot: snapshot, dueCount: due.length),
                const SizedBox(height: AppSpacing.md),
                _ExamDayLink(onTap: () => context.push('/exam-day')),
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
                const SizedBox(height: AppSpacing.lg),
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
                const SizedBox(height: AppSpacing.lg),
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
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Daily Companion is unavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your saved revision queue is still on this device. Try loading it again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.snapshot, required this.dueCount});

  final DailyCompanionSnapshot snapshot;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final goal = snapshot.settings.dailyQuestionGoal;
    final progress = goal <= 0
        ? 0.0
        : (snapshot.completedToday / goal).clamp(0.0, 1.0).toDouble();

    return Container(
      key: const Key('daily-summary'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s revision',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dueCount == 0
                          ? 'You are caught up for now.'
                          : '$dueCount ${dueCount == 1 ? 'question is' : 'questions are'} due now.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '$dueCount due',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
              color: scheme.secondary,
              backgroundColor: scheme.surface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${snapshot.completedToday} of $goal reviews completed today',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamDayLink extends StatelessWidget {
  const _ExamDayLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Countdown, logistics checklist and local reminders',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
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
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final minutes in const [5, 10, 20])
          FilledButton.tonalIcon(
            key: Key('quick-revision-$minutes'),
            onPressed: enabled ? () => onOpen(minutes) : null,
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: Text('$minutes min'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(104, 48),
            ),
          ),
      ],
    );
  }
}

class _EmptyRevisionQueue extends StatelessWidget {
  const _EmptyRevisionQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('revision-queue-empty'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Complete tests to build a private revision queue from wrong, skipped, flagged and unusually slow questions.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
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

    return Card(
      key: Key('revision-item-${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: due
                        ? theme.colorScheme.tertiaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    due ? 'Due' : _date(item.dueAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: due
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              [item.testName, item.section]
                  .where((value) => value.trim().isNotEmpty)
                  .join(' · '),
              maxLines: 1,
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        reason.label,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
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

    return Card(
      key: const Key('study-plan'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'My study plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Set a realistic daily review target and an optional local reminder.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _GoalControl(
              settings: settings,
              stacked: textScale >= 1.5,
              onChanged: onChanged,
            ),
            const Divider(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Local study reminder'),
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
              fontWeight: FontWeight.w800,
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

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily question goal'),
          const SizedBox(height: AppSpacing.sm),
          controls,
        ],
      );
    }

    return Row(
      children: [
        const Expanded(child: Text('Daily question goal')),
        const SizedBox(width: AppSpacing.sm),
        controls,
      ],
    );
  }
}

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
