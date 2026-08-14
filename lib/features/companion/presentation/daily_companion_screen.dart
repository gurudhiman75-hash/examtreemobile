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
        error: (error, stackTrace) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(dailyCompanionSnapshotProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Daily Companion'),
          ),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _TodayCard(snapshot: snapshot, dueCount: due.length),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.event_available_outlined),
                    title: const Text('Exam-Day Mode'),
                    subtitle: const Text('Countdown, logistics checklist and local reminders'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/exam-day'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick revision',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [5, 10, 20]
                      .map(
                        (minutes) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: minutes == 20 ? 0 : 8,
                            ),
                            child: FilledButton.tonal(
                              onPressed: due.isEmpty
                                  ? null
                                  : () => _openQuickRevision(context, minutes),
                              child: Text('$minutes min'),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 24),
                Text(
                  'Revision queue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  due.isEmpty
                      ? '${snapshot.items.length} saved questions • nothing due now'
                      : '${due.length} due now • ${snapshot.items.length} saved',
                ),
                const SizedBox(height: 8),
                if (snapshot.items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Complete tests to build a private revision queue from wrong, skipped, flagged and unusually slow questions.',
                      ),
                    ),
                  )
                else
                  ...snapshot.items.take(8).map(
                        (item) => Card(
                          child: ListTile(
                            leading: Icon(
                              item.isDue(now)
                                  ? Icons.notifications_active_outlined
                                  : Icons.schedule_outlined,
                            ),
                            title: Text(
                              item.questionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.reasons
                                  .map((reason) => reason.label)
                                  .join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              item.isDue(now) ? 'Due' : _date(item.dueAt),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
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

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.snapshot, required this.dueCount});
  final DailyCompanionSnapshot snapshot;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final goal = snapshot.settings.dailyQuestionGoal;
    final progress = (snapshot.completedToday / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s revision',
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dueCount == 0 ? 'You are caught up.' : '$dueCount questions are due.',
            style: TextStyle(color: scheme.onPrimary),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 8),
          Text(
            '${snapshot.completedToday} of $goal reviews completed today',
            style: TextStyle(color: scheme.onPrimary),
          ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My study plan', style: TextStyle(fontWeight: FontWeight.w900)),
            Row(
              children: [
                const Expanded(child: Text('Daily question goal')),
                IconButton(
                  onPressed: settings.dailyQuestionGoal > 1
                      ? () => onChanged(settings.copyWith(
                            dailyQuestionGoal: settings.dailyQuestionGoal - 1,
                          ))
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${settings.dailyQuestionGoal}'),
                IconButton(
                  onPressed: settings.dailyQuestionGoal < 100
                      ? () => onChanged(settings.copyWith(
                            dailyQuestionGoal: settings.dailyQuestionGoal + 1,
                          ))
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Local study reminder'),
              subtitle: Text(TimeOfDay(
                hour: settings.reminderHour,
                minute: settings.reminderMinute,
              ).format(context)),
              value: settings.reminderEnabled,
              onChanged: (value) =>
                  onChanged(settings.copyWith(reminderEnabled: value)),
            ),
            if (settings.reminderEnabled)
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
                    onChanged(settings.copyWith(
                      reminderHour: picked.hour,
                      reminderMinute: picked.minute,
                    ));
                  }
                },
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Change reminder time'),
              ),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime value) {
  final local = value.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${local.day} ${months[local.month - 1]}';
}
